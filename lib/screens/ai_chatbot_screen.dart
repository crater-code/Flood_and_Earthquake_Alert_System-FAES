// lib/screens/ai_chatbot_screen.dart
// PURPOSE: Emergency response chatbot with pre-fed quick actions
// TYPE: StatefulWidget (needs to manage chat messages dynamically)
// KEY FEATURES: Quick action buttons, chat history, AI responses

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/backend_service.dart';

/// StatefulWidget = can change state (messages can be added/removed)
/// StatelessWidget = immutable (doesn't change after creation)
class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your AI disaster response assistant. Tap any quick action below or ask me anything about emergency response.",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  // Pre-fed responses for quick actions
  static const Map<String, String> quickResponses = {
    'Flood Safety': "**Flood Safety Guidelines:**\n\n"
        "1. Move to higher ground immediately\n"
        "2. Never drive through flood waters\n"
        "3. Avoid walking in moving water\n"
        "4. Stay away from downed power lines\n"
        "5. Turn off utilities if time permits\n"
        "6. Keep emergency supplies ready\n"
        "7. Have evacuation route planned\n\n"
        "Call emergency services if trapped or in danger.",
    
    '🏚️ Earthquake Safety': "**Earthquake Safety Guidelines:**\n\n"
        "**During earthquake:**\n"
        "1. DROP, COVER, and HOLD ON\n"
        "2. Get under sturdy table/desk\n"
        "3. Cover head and neck\n"
        "4. Stay away from windows\n"
        "5. Avoid using elevators\n\n"
        "**After earthquake:**\n"
        "1. Check for injuries\n"
        "2. Inspect for hazards\n"
        "3. Be prepared for aftershocks\n"
        "4. Stay in safe location\n\n"
        "Exit building only if safe.",
    
    '🔥 Fire Safety': "**Fire Safety Guidelines:**\n\n"
        "1. Get out immediately\n"
        "2. Close doors behind you\n"
        "3. Feel doors for heat\n"
        "4. Crawl under smoke\n"
        "5. Go to designated meeting spot\n"
        "6. Call 911 from outside\n"
        "7. Never go back inside\n\n"
        "Prevention: Have fire extinguishers, smoke alarms, evacuation plans.",
    
    '🚨 Emergency Kit': "**Essential Emergency Kit:**\n\n"
        "Water: 1 gallon per person per day\n"
        "Food: Non-perishable items\n"
        "First aid kit & medications\n"
        "Flashlight & extra batteries\n"
        "Radio (battery/hand-crank)\n"
        "Whistle for signaling\n"
        "Dust mask & plastic sheeting\n"
        "Moist towelettes & garbage bags\n"
        "Wrench or pliers for utilities\n"
        "Manual can opener\n"
        "Local maps & important documents\n"
        "Cash & credit cards\n"
        "Change of clothes & sturdy shoes\n\n"
        "Update supplies every 6 months.",
    
    '📍 Evacuation Plan': "**Create Your Evacuation Plan:**\n\n"
        "1. Know two evacuation routes\n"
        "2. Identify meeting points (near home, city)\n"
        "3. Plan for family members\n"
        "4. Prepare pet evacuation plan\n"
        "5. Have important documents ready\n"
        "6. Keep emergency contact list\n"
        "7. Practice evacuation routes\n"
        "8. Know shelter locations\n"
        "9. Have transportation plan\n"
        "10. Stay informed via emergency alerts\n\n"
        "Review plan annually with family.",
    
    '📞 Emergency Hotlines': "**Emergency Contact Numbers (Pakistan):**\n\n"
        "Emergency Services: 15\n"
        "Police Emergency: 15\n"
        "Fire Emergency: 16\n"
        "Ambulance/Medical: 1122\n"
        "Disaster Management Authority (NDMA): 0800-24000\n"
        "Pakistan Red Crescent: 021-111-22-6622\n"
        "Mental Health Crisis: 0333-111-5717\n"
        "Earthquake/Disaster Info: 021-111-HELP (4357)\n\n"
        "Save these numbers in your phone and keep written copies.",
  };

  void _sendQuickResponse(String title) {
    final response = quickResponses[title] ?? "Information not available";
    
    setState(() {
      _messages.add(ChatMessage(
        text: title,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _getAIResponse(_messageController.text.trim()),
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    });

    _messageController.clear();
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    if (message.contains('flood')) {
      return "**Flood Safety Guidelines:**\n\n"
          "1. Move to higher ground immediately\n"
          "2. Never drive through flood waters\n"
          "3. Avoid walking in moving water\n"
          "4. Stay away from downed power lines\n"
          "5. Turn off utilities if time permits\n"
          "6. Keep emergency supplies ready\n"
          "7. Have evacuation route planned\n\n"
          "For immediate help, call your local emergency services.";
    } else if (message.contains('earthquake')) {
      return "**Earthquake Safety Guidelines:**\n\n"
          "**During earthquake:**\n"
          "• DROP, COVER, and HOLD ON\n"
          "• Get under sturdy table/desk\n"
          "• Cover head and neck\n"
          "• Stay away from windows\n"
          "• Avoid using elevators\n\n"
          "**After earthquake:**\n"
          "• Check for injuries\n"
          "• Inspect for hazards\n"
          "• Be prepared for aftershocks\n"
          "• Stay informed via emergency broadcasts";
    } else if (message.contains('help') || message.contains('emergency')) {
      return "I'm here to help! For immediate emergencies, call 911. Use the quick action buttons below to access essential safety information. What do you need?";
    } else if (message.contains('fire')) {
      return "**Fire Safety Guidelines:**\n\n"
          "1. Alert others immediately\n"
          "2. Evacuate without using elevators\n"
          "3. Feel doors before opening\n"
          "4. Stay low to avoid smoke\n"
          "5. Move away from the building\n"
          "6. Don't return for belongings\n"
          "7. Call 16 (Fire Emergency) from safe location\n\n"
          "Prevention: Test smoke alarms, have escape plan, keep exits clear.";
    } else if (message.contains('kit') || message.contains('supplies')) {
      return "**Emergency Kit Checklist:**\n\n"
          "Essential Items:\n"
          "✓ Water (1 gallon per person per day)\n"
          "✓ Non-perishable food (3-day supply)\n"
          "✓ First aid kit\n"
          "✓ Medications (prescription + OTC)\n"
          "✓ Flashlight + extra batteries\n"
          "✓ Battery/hand-crank radio\n"
          "✓ Cash and credit cards\n"
          "✓ Important documents (copies)\n"
          "✓ Personal hygiene items\n"
          "✓ Change of clothes\n"
          "✓ Blanket/sleeping bag\n"
          "✓ Phone chargers + portable battery\n"
          "✓ Pet supplies (if applicable)";
    } else {
      return "I can help with disaster response and emergency preparedness. Try the quick action buttons below for specific topics, or ask me about emergency procedures, safety guidelines, evacuation planning, or emergency kits.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: const Text('AI Emergency Assistant'),
        backgroundColor: AppTheme.slate50,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
              reverse: false,
            ),
          ),
          _buildQuickActions(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: message.isUser ? Colors.white : AppTheme.slate800,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.slate300,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.slate500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickResponses.keys.map((action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    onPressed: () => _sendQuickResponse(action),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    label: Text(action),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about disaster response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.slate50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: 1,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
              tooltip: 'Send message',
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}