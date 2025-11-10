import sqlite3
import os

DB_PATH = 'sign_language.db'

def init_database():
    """
    Create SQLite database & tables
    """
    print(f"Creating SQLite database: {DB_PATH}")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create word_videos table
    print("Creating word_videos table...")
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS word_videos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label VARCHAR(100) NOT NULL UNIQUE,
            video_path VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Insert sample data
    print("Inserting sample words...")
    sample_words = [
        ('apple', 'videos/words/apple.mp4'),
        ('are', 'videos/words/are.mp4'),
        ('book', 'videos/words/book.mp4'),
        ('cat', 'videos/words/cat.mp4'),
        ('dog', 'videos/words/dog.mp4'),
        ('drink', 'videos/words/drink.mp4'),
        ('eat', 'videos/words/eat.mp4'),
        ('face', 'videos/words/face.mp4'),
        ('father', 'videos/words/father.mp4'),
        ('food', 'videos/words/food.mp4'),
        ('go', 'videos/words/go.mp4'),
        ('hand', 'videos/words/hand.mp4'),
        ('hello', 'videos/words/hello.mp4'),
        ('how', 'videos/words/how.mp4'),
        ('i', 'videos/words/i.mp4'),
        ('leg', 'videos/words/leg.mp4'),
        ('listen', 'videos/words/listen.mp4'),
        ('man', 'videos/words/man.mp4'),
        ('me', 'videos/words/me.mp4'),
        ('morning', 'videos/words/morning.mp4'),
        ('mother', 'videos/words/mother.mp4'),
        ('music', 'videos/words/music.mp4'),
        ('name', 'videos/words/name.mp4'),
        ('pen', 'videos/words/pen.mp4'),
        ('phone', 'videos/words/phone.mp4'),
        ('red', 'videos/words/red.mp4'),
        ('say', 'videos/words/say.mp4'),
        ('table', 'videos/words/table.mp4'),
        ('thank', 'videos/words/thank.mp4'),
        ('water', 'videos/words/water.mp4'),
        ('woman', 'videos/words/woman.mp4'),
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
