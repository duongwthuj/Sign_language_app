from flask import Flask, request, jsonify, Response, send_file, url_for
from flask_cors import CORS
import sqlite3
import os
import re
import traceback

app = Flask(__name__)
CORS(app)

# ============================================
# CONFIG
# ============================================
DB_PATH = 'sign_language.db'
VIDEO_FOLDER = 'videos'
WORD_VIDEO_FOLDER = os.path.join(VIDEO_FOLDER, 'words')
OUTPUT_FOLDER = os.path.join(VIDEO_FOLDER, 'output')

os.makedirs(WORD_VIDEO_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)



def get_db_connection():
    """Create SQLite connection"""
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    except sqlite3.Error as e:
        app.logger.error(f"SQLite Error: {e}")
        return None


def get_video_path_by_word(word):
    """Get video_path from DB by word"""
    connection = get_db_connection()
    if not connection:
        return None

    try:
        cursor = connection.cursor()
        query = "SELECT video_path FROM word_videos WHERE LOWER(label) = LOWER(?)"
        cursor.execute(query, (word,))
        result = cursor.fetchone()
        if result:
            return result['video_path']
        return None
    except sqlite3.Error as e:
        app.logger.error(f"Database error: {e}")
        return None
    finally:
        connection.close()


def split_text_to_words(text):
    """Split text into lowercase words"""
    text = re.sub(r'[^\w\s]', '', text)
    return [w.strip().lower() for w in text.split() if w.strip()]



@app.route('/health', methods=['GET'])
def health_check():
    try:
        conn = get_db_connection()
        db_status = "connected" if conn else "disconnected"
        if conn:
            conn.close()
    except Exception:
        db_status = "error"

    return jsonify({
        'status': 'running',
        'database': db_status,
        'word_videos': len(os.listdir(WORD_VIDEO_FOLDER)) if os.path.exists(WORD_VIDEO_FOLDER) else 0,
        'output_videos': len(os.listdir(OUTPUT_FOLDER)) if os.path.exists(OUTPUT_FOLDER) else 0
    }), 200



@app.route('/api/generate-video', methods=['POST'])
def generate_video():
    try:
        data = request.get_json() or {}
        text = data.get('text', '')
        language = data.get('language', 'en_US')

        app.logger.info(f"Received text: '{text}' ({language})")

        if not text.strip():
            return jsonify({'error': 'Text is required'}), 400

        words = split_text_to_words(text)
        if not words:
            return jsonify({'error': 'No valid words found'}), 400

        video_paths, missing_words = [], []

        for word in words:
            path = get_video_path_by_word(word)
            if path and os.path.exists(path):
                video_paths.append(path)
            else:
                missing_words.append(word)

        if not video_paths:
            return jsonify({'error': 'No videos found', 'missing_words': missing_words}), 404

        # Build accessible URLs
        video_urls = []
        for path in video_paths:
            rel = os.path.relpath(path, VIDEO_FOLDER).replace("\\", "/")
            url = url_for('serve_video', filename=rel, _external=True)
            video_urls.append(url)

        app.logger.info(f"Returning {len(video_urls)} video URLs")

        return jsonify({
            'success': True,
            'text': text,
            'words': words,
            'video_count': len(video_urls),
            'videoUrls': video_urls,
            'missing_words': missing_words,
            'language': language
        }), 200

    except Exception as e:
        app.logger.error(f"Error in generate_video: {e}")
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


@app.route('/videos/<path:filename>')
def serve_video(filename):
    """
    Serve video files properly for ExoPlayer (supports Range header).
    """
    try:
        safe_path = os.path.normpath(filename).replace("..", "")
        video_path = os.path.join(VIDEO_FOLDER, safe_path)
        video_path = os.path.abspath(video_path)

        if not os.path.exists(video_path):
            return jsonify({'error': 'Video not found'}), 404

        file_size = os.path.getsize(video_path)
        range_header = request.headers.get('Range', None)

        if range_header:
            match = re.search(r'bytes=(\d+)-(\d*)', range_header)
            if match:
                start = int(match.group(1))
                end = match.group(2)
                end = int(end) if end else file_size - 1
            else:
                start, end = 0, file_size - 1

            if start >= file_size:
                return Response(status=416)

            length = end - start + 1
            with open(video_path, 'rb') as f:
                f.seek(start)
                data = f.read(length)

            rv = Response(data, 206, content_type='video/mp4', direct_passthrough=True)
            rv.headers.add('Content-Range', f'bytes {start}-{end}/{file_size}')
            rv.headers.add('Accept-Ranges', 'bytes')
            rv.headers.add('Access-Control-Allow-Origin', '*')
            rv.headers.add('Content-Length', str(length))
            return rv
        else:
            with open(video_path, 'rb') as f:
                data = f.read()
            rv = Response(data, 200, content_type='video/mp4', direct_passthrough=True)
            rv.headers.add('Accept-Ranges', 'bytes')
            rv.headers.add('Access-Control-Allow-Origin', '*')
            rv.headers.add('Content-Length', str(file_size))
            return rv

    except Exception as e:
        app.logger.error(f"Error serving video: {e}")
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


# ============================================
# GET / ADD WORDS
# ============================================
@app.route('/api/words', methods=['GET'])
def get_all_words():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'DB failed'}), 500
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, label, video_path FROM word_videos ORDER BY label")
        words = cursor.fetchall()
        return jsonify({
            'success': True,
            'count': len(words),
            'words': [dict(w) for w in words]
        }), 200
    finally:
        conn.close()


@app.route('/api/words', methods=['POST'])
def add_word():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'DB failed'}), 500
    try:
        data = request.get_json() or {}
        label = data.get('label', '').strip().lower()
        video_path = data.get('video_path', '').strip()
        if not label or not video_path:
            return jsonify({'error': 'label and video_path required'}), 400
        cursor = conn.cursor()
        cursor.execute("INSERT INTO word_videos (label, video_path) VALUES (?, ?)", (label, video_path))
        conn.commit()
        return jsonify({'success': True, 'message': f"Added '{label}'"}), 201
    except sqlite3.IntegrityError:
        return jsonify({'error': 'Word already exists'}), 400
    finally:
        conn.close()


# ============================================
# MAIN
# ============================================
if __name__ == '__main__':
    app.logger.info("=" * 60)
    app.logger.info("Sign Language API Server with SQLite")
    app.logger.info(f"Videos folder: {os.path.abspath(VIDEO_FOLDER)}")
    app.logger.info(f"Database: {os.path.abspath(DB_PATH)}")
    app.logger.info("Running on 0.0.0.0:5000 (LAN accessible)")
    app.logger.info("=" * 60)
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
