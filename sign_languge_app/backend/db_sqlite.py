import sqlite3
import os

DB_PATH = 'sign_language.db'

def init_database():
    """
    Tạo SQLite database & tables
    """
    print(f"📦 Creating SQLite database: {DB_PATH}")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Tạo bảng word_videos
    print("📋 Creating word_videos table...")
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS word_videos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label VARCHAR(100) NOT NULL UNIQUE,
            video_path VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Insert sample data
    print("📝 Inserting sample words...")
    sample_words = [
        ('hello', 'videos/words/hello.mp4'),
        ('are', 'videos/words/are.mp4'),
        ('how', 'videos/words/how.mp4'),
        ('thank', 'videos/words/thank.mp4'),
        ('you', 'videos/words/you.mp4'),
    ]
    
    for label, path in sample_words:
        try:
            cursor.execute(
                'INSERT INTO word_videos (label, video_path) VALUES (?, ?)',
                (label, path)
            )
            print(f"  ✅ Added: {label}")
        except sqlite3.IntegrityError:
            print(f"  ⚠️  Already exists: {label}")
    
    conn.commit()
    conn.close()
    
    print("=" * 60)
    print("✅ SQLite Database initialized successfully!")
    print(f"📂 Database file: {os.path.abspath(DB_PATH)}")
    print("=" * 60)

if __name__ == '__main__':
    init_database()
