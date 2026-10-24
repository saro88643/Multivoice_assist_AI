from flask import Blueprint, request, jsonify
from services.ai_service import ai_service

chatbot_bp = Blueprint('chatbot', __name__)

@chatbot_bp.route('/api/chat', methods=['POST'])
def chat():
    data = request.get_json() or {}
    message = data.get('message', '').strip()
    language = data.get('language', 'en')
    context = data.get('context', '')
    history = data.get('history', [])
    model_id = data.get('model_id', None)

    if not message:
        return jsonify({
            'success': False,
            'message': 'Message cannot be empty.'
        }), 400

    result = ai_service.generate_response(
        user_message=message,
        language=language,
        context=context,
        history=history,
        custom_model_id=model_id
    )

    return jsonify(result)
