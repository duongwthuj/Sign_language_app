from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import sqlite3
import os
from datetime import datetime
import re

app = Flask(__name__)
CORS(app)

# ============================================
# CẤU HÌNH
# ============================================
DB_PATH = 'sign_language.db'
VIDEO_FOLDER = 'videos'
WORD_VIDEO_FOLDER = os.path.join(VIDEO_FOLDER, 'words')
OUTPUT_FOLDER = os.path.join(VIDEO_FOLDER, 'output')

os.makedirs(WORD_VIDEO_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# ============================================
# KẾT NỐI SQLite
# ============================================
def get_db_connection():
    """Tao ket noi SQLite"""
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    except sqlite3.Error as e:
        print(f"SQLite Error: {e}")
        return None


def get_video_path_by_word(word):
    """
    Lay video path tu database theo word (label)
    """
    connection = get_db_connection()
    if not connection:
        return None
    
    try:
        cursor = connection.cursor()
        
        # Query tim video theo label (case-insensitive)
        query = "SELECT video_path FROM word_videos WHERE LOWER(label) = LOWER(?)"
        cursor.execute(query, (word,))
        
        result = cursor.fetchone()
        
        if result:
            print(f"Found video for '{word}': {result['video_path']}")
            return result['video_path']
        else:
            print(f"No video found for word: '{word}'")
            return None
            
    except sqlite3.Error as e:
        print(f"Database error: {e}")
        return None
    finally:
        if connection:
            connection.close()


def split_text_to_words(text):
    """
    Tach text thanh cac tu
    - Loai bo dau cau
    - Chuyen ve lowercase
    - Loai bo khoang trang thua
    """
    # Loai bo dau cau, chi giu chu cai va so
    text = re.sub(r'[^\w\s]', '', text)
    
    # Tach thanh cac tu va loai bo tu rong
    words = [word.strip().lower() for word in text.split() if word.strip()]
    
    print(f"Split text into {len(words)} words: {words}")
    return words


# ============================================
# API: Health Check
# ============================================
@app.route('/health', methods=['GET'])
def health_check():
    """Health check + Database status"""
    try:
        conn = get_db_connection()
        if conn:
            conn.close()
            db_status = "connected"
        else:
            db_status = "disconnected"
    except:
        db_status = "error"
    
    # Count videos
    word_videos = len([f for f in os.listdir(WORD_VIDEO_FOLDER) if f.endswith('.mp4')]) if os.path.exists(WORD_VIDEO_FOLDER) else 0
    output_videos = len([f for f in os.listdir(OUTPUT_FOLDER) if f.endswith('.mp4')]) if os.path.exists(OUTPUT_FOLDER) else 0
    
    return jsonify({
        'status': 'running',
        'database': db_status,
        'word_videos_count': word_videos,
        'output_videos_count': output_videos,
        'folders': {
            'words': os.path.abspath(WORD_VIDEO_FOLDER),
            'output': os.path.abspath(OUTPUT_FOLDER)
        }
    }), 200


# ============================================
# API: Generate Sign Language Video
# ============================================
@app.route('/api/generate-video', methods=['POST'])
def generate_video():
    """
    Nhận text, tách thành words, lấy video từ database
    """
    try:
        data = request.get_json()
        text = data.get('text', '')
        language = data.get('language', 'en_US')
        
        print("=" * 60)
        print(f"Received request:")
        print(f"   Text: '{text}'")
        print(f"   Language: {language}")
        print("=" * 60)
        
        if not text or text.strip() == '':
            return jsonify({'error': 'Text is required'}), 400
        
        # Step 1: Split text into words
        words = split_text_to_words(text)
        
        if not words:
            return jsonify({'error': 'No valid words found'}), 400
        
        # Step 2: Get video paths from database
        video_paths = []
        missing_words = []
        
        for word in words:
            video_path = get_video_path_by_word(word)
            
            if video_path and os.path.exists(video_path):
                video_paths.append(video_path)
            else:
                missing_words.append(word)
                print(f"Missing video for word: '{word}'")
        
        if not video_paths:
            return jsonify({
                'error': 'No videos found for any words',
                'missing_words': missing_words
            }), 404
        
        # Step 3: Build video URLs
        host = request.host
        video_urls = [f"http://{host}/{video_path}" for video_path in video_paths]
        
        print(f"Success! Generated {len(video_urls)} video URLs")
        print(f"   Videos: {video_urls}")
        print("=" * 60)
        
        # Response - return list of video URLs
        response = {
            'success': True,
            'videoUrls': video_urls,
            'text': text,
            'words': words,
            'video_count': len(video_urls),
            'missing_words': missing_words if missing_words else [],
            'language': language,
            'message': 'Sign language videos found successfully'
        }
        
        return jsonify(response), 200
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


# ============================================
# API: Serve Videos
# ============================================
@app.route('/videos/<path:filename>')
def serve_video(filename):
    """Serve video files - /videos/words/hello.mp4"""
    try:
        video_path = os.path.join(VIDEO_FOLDER, filename)
        
        print(f"Serving video: {video_path}")
        
        if not os.path.exists(video_path):
            return jsonify({'error': 'Video not found'}), 404
        
        response = send_file(video_path, mimetype='video/mp4')
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Accept-Ranges'] = 'bytes'
        
        return response
        
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 500


# ============================================
# API: Get All Words
# ============================================
@app.route('/api/words', methods=['GET'])
def get_all_words():
    """Get list of all words from database"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor()
        query = "SELECT id, label, video_path, created_at FROM word_videos ORDER BY label"
        cursor.execute(query)
        words = cursor.fetchall()
        
        return jsonify({
            'success': True,
            'count': len(words),
            'words': [dict(w) for w in words]
        }), 200
        
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection:
            connection.close()


# ============================================
# API: Add Word
# ============================================
@app.route('/api/words', methods=['POST'])
def add_word():
    """Add new word to database - Body: {"label": "hello", "video_path": "videos/words/hello.mp4"}"""
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        data = request.get_json()
        label = data.get('label', '').strip().lower()
        video_path = data.get('video_path', '').strip()
        
        if not label or not video_path:
            return jsonify({'error': 'label and video_path are required'}), 400
        
        cursor = connection.cursor()
        
        query = "INSERT INTO word_videos (label, video_path) VALUES (?, ?)"
        cursor.execute(query, (label, video_path))
        
        connection.commit()
        
        return jsonify({
            'success': True,
            'message': f"Word '{label}' added successfully",
            'id': cursor.lastrowid
        }), 201
        
    except sqlite3.IntegrityError:
        return jsonify({'error': f"Word '{label}' already exists"}), 400
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if connection:
            connection.close()

# ============================================
# MAIN - Start Server
# ============================================
if __name__ == '__main__':
    print("=" * 60)
    print("Sign Language API Server with SQLite")
    print("=" * 60)
    print(f"Word videos: {os.path.abspath(WORD_VIDEO_FOLDER)}")
    print(f"Output videos: {os.path.abspath(OUTPUT_FOLDER)}")
    print(f"Database: {os.path.abspath(DB_PATH)}")
    print(f"Server: http://localhost:5000")
    print("=" * 60)
    print("Endpoints:")
    print("   GET  /health")
    print("   POST /api/generate-video")
    print("   GET  /api/words")
    print("   POST /api/words")
    print("   GET  /videos/<path>")
    print("=" * 60)
    
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)