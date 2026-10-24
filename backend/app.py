from flask import Flask, jsonify
from flask_cors import CORS
from config import Config
from routes.chatbot import chatbot_bp

app = Flask(__name__)
CORS(app)

app.register_blueprint(chatbot_bp)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'healthy',
        'app': 'MultiVoice Assist AI Backend',
        'hf_model_id': Config.HF_MODEL_ID,
        'has_token': bool(Config.HF_API_TOKEN)
    })

if __name__ == '__main__':
    print("==================================================")
    print(f"MultiVoice Assist Backend Proxy Starting...")
    print(f"Hugging Face Model ID: {Config.HF_MODEL_ID}")
    print(f"Port: {Config.PORT}")
    print("==================================================")
    app.run(host=Config.HOST, port=Config.PORT, debug=Config.DEBUG)
