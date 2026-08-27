import '../models/chat_message.dart';

class ChatBotService {
  // For demo purposes - using a rule-based system
  // You can replace this with actual AI API (OpenAI, etc.)
  
  static Future<ChatMessage> getResponse(String userMessage) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerMessage = userMessage.toLowerCase().trim();
    
    // Check for common patterns and respond
    String response = _getRuleBasedResponse(lowerMessage);
    List<QuickReply>? quickReplies = _getQuickReplies(lowerMessage);
    
    return ChatMessage.bot(response, quickReplies: quickReplies);
  }

  static String _getRuleBasedResponse(String message) {
    // ==================== GREETINGS ====================
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return '👋 Hello! I\'m your Tax Filing Assistant. I can help you with:\n\n'
          '• Filing your tax return\n'
          '• Understanding PAYE, VAT, and other taxes\n'
          '• Claiming deductions\n'
          '• Payment methods\n'
          '• TRA regulations\n\n'
          'What would you like to know?';
    }

    // ==================== TIN ====================
    if (message.contains('tin') || message.contains('tax id') || message.contains('registration')) {
      return '📋 **TIN (Taxpayer Identification Number)**\n\n'
          'A TIN is a unique 9-digit number issued by TRA for identification in tax matters.\n\n'
          '**How to get a TIN:**\n'
          '1. Visit the TRA website (www.tra.go.tz)\n'
          '2. Fill the online registration form\n'
          '3. Submit required documents:\n'
          '   • Copy of ID/Passport\n'
          '   • Passport photo\n'
          '   • Proof of address\n'
          '4. Your TIN will be issued within 3-5 working days\n\n'
          'You can also visit any TRA office for assistance.';
    }

    // ==================== PAYE ====================
    if (message.contains('paye') || message.contains('pay as you earn')) {
      return '💰 **PAYE (Pay As You Earn)**\n\n'
          'PAYE is tax deducted from employment income by employers.\n\n'
          '**Tanzania PAYE Rates (2024):**\n'
          '• TSh 0 - 270,000 → 0%\n'
          '• TSh 270,001 - 520,000 → 8%\n'
          '• TSh 520,001 - 760,000 → 20%\n'
          '• TSh 760,001 - 1,000,000 → 25%\n'
          '• TSh 1,000,001 - 10,000,000 → 30%\n'
          '• Above TSh 10,000,000 → 35%\n\n'
          '**Personal Relief:** TSh 270,000 per year is automatically applied.\n'
          'Your employer calculates and deducts PAYE monthly.';
    }

    // ==================== VAT ====================
    if (message.contains('vat') || message.contains('value added tax')) {
      return '📊 **VAT (Value Added Tax)**\n\n'
          'VAT is a consumption tax charged on goods and services.\n\n'
          '**Tanzania VAT Rates:**\n'
          '• Standard Rate: 18%\n'
          '• Zero-rated: 0% (exports, etc.)\n'
          '• Exempt: Healthcare, Education, etc.\n\n'
          '**Registration Threshold:**\n'
          '• Mandatory: Turnover > TSh 10,000,000/year\n'
          '• Voluntary: Turnover below threshold\n\n'
          'VAT returns are filed monthly by the 20th.';
    }

    // ==================== DEDUCTIONS ====================
    if (message.contains('deduction') || message.contains('relief') || 
        message.contains('claim') || message.contains('deduct')) {
      return '📝 **Deductions & Reliefs**\n\n'
          'You can claim the following deductions to reduce your tax:\n\n'
          '**Mandatory Relief:**\n'
          '• Personal Relief: TSh 270,000/year\n\n'
          '**Common Deductions:**\n'
          '• Pension contributions\n'
          '• Insurance premiums (Life, Health)\n'
          '• Medical expenses (up to TSh 100,000)\n'
          '• Charitable donations (registered organizations)\n'
          '• Education expenses (tuition fees)\n'
          '• Mortgage interest\n'
          '• Business expenses\n\n'
          '⚠️ Keep all receipts and documents for verification!';
    }

    // ==================== DEADLINE ====================
    if (message.contains('deadline') || message.contains('due') || 
        message.contains('when') || message.contains('submit')) {
      return '📅 **Filing Deadlines**\n\n'
          '**Key Dates:**\n'
          '• Individual Returns: **30th June**\n'
          '• Corporate Returns: **31st December**\n'
          '• VAT Returns: **20th of each month**\n'
          '• PAYE Returns: **15th of each month**\n\n'
          '⚠️ **Penalties for Late Filing:**\n'
          '• 5% penalty per month on tax due\n'
          '• Interest of 0.01% per day on overdue\n\n'
          'File early to avoid penalties!';
    }

    // ==================== PAYMENT ====================
    if (message.contains('payment') || message.contains('pay') || 
        message.contains('mpesa') || message.contains('tigo') || 
        message.contains('airtel')) {
      return '💳 **Payment Methods**\n\n'
          'You can pay taxes through:\n\n'
          '**Mobile Money:**\n'
          '• 📱 M-Pesa: Dial *150*00#\n'
          '• 📱 Tigo Pesa: Dial *150*01#\n'
          '• 📱 Airtel Money: Dial *150*02#\n\n'
          '**Other Methods:**\n'
          '• 🏦 Bank Transfer (any commercial bank)\n'
          '• 💰 TRA Offices (Cash/Card)\n'
          '• 💻 Online Banking\n\n'
          'Always use your Control Number when making payments.';
    }

    // ==================== DOCUMENTS ====================
    if (message.contains('document') || message.contains('required') || 
        message.contains('need') || message.contains('paper')) {
      return '📄 **Required Documents for Filing**\n\n'
          '**Essential Documents:**\n'
          '• TIN Certificate\n'
          '• Employment Letter / Payslips (if employed)\n'
          '• Business Registration (if self-employed)\n'
          '• Bank Statements\n'
          '• Rental Agreements (if you have rental income)\n\n'
          '**For Deductions:**\n'
          '• Pension Contribution Receipts\n'
          '• Insurance Premium Receipts\n'
          '• Medical Expense Receipts\n'
          '• Donation Receipts (registered charities)\n'
          '• Education Expense Receipts\n\n'
          'Keep all documents safe for at least 5 years!';
    }

    // ==================== PENALTIES ====================
    if (message.contains('penalty') || message.contains('late') || 
        message.contains('fine') || message.contains('interest')) {
      return '⚠️ **Penalties for Non-Compliance**\n\n'
          '**Late Filing:**\n'
          '• 5% penalty per month (up to 100% of tax due)\n'
          '• Interest: 0.01% per day on outstanding amount\n\n'
          '**Other Penalties:**\n'
          '• False declaration: Up to 300% of tax due\n'
          '• Failure to register: TSh 100,000 - 1,000,000\n'
          '• Failure to keep records: TSh 50,000 - 500,000\n\n'
          '**How to Avoid Penalties:**\n'
          '✅ File returns on time\n'
          '✅ Pay taxes when due\n'
          '✅ Keep accurate records\n'
          '✅ Declare all income sources';
    }

    // ==================== CONTACT ====================
    if (message.contains('contact') || message.contains('phone') || 
        message.contains('email') || message.contains('support') || 
        message.contains('tra')) {
      return '📞 **TRA Contact Information**\n\n'
          '**Tanzania Revenue Authority (TRA)**\n\n'
          '📱 Call Center: +255 22 123 4567\n'
          '📧 Email: support@tra.go.tz\n'
          '💬 WhatsApp: +255 712 345 678\n\n'
          '**TRA Office Locations:**\n'
          '• Dar es Salaam: Kivukoni\n'
          '• Arusha: Clock Tower\n'
          '• Mwanza: Posta Area\n'
          '• Mbeya: Uhindini\n'
          '• Dodoma: Government City\n\n'
          '🕐 Office Hours: Mon-Fri 8:00am - 5:00pm';
    }

    // ==================== TAX COMPUTATION ====================
    if (message.contains('calculate') || message.contains('compute') || 
        message.contains('how much') || message.contains('tax amount')) {
      return '🧮 **Tax Computation**\n\n'
          'I can help you estimate your tax.\n\n'
          '**For PAYE:**\n'
          '1. Calculate annual income\n'
          '2. Subtract personal relief (TSh 270,000)\n'
          '3. Apply the correct tax rates\n\n'
          '**For VAT:**\n'
          '• 18% of taxable sales\n\n'
          '**For Business:**\n'
          '• Skills Levy: 5% of turnover\n'
          '• Railway Levy: 5% of turnover\n'
          '• Corporate Tax: 30% - 35% of profit\n\n'
          'You can use our **Tax Calculator** in the menu to get your exact tax amount!';
    }

    // ==================== QUICK HELP ====================
    if (message.contains('help') || message.contains('assist') || 
        message.contains('support') || message.contains('guide')) {
      return '🤖 **How Can I Help You?**\n\n'
          'I can assist you with:\n\n'
          '📋 **Tax Filing:** Step-by-step guidance\n'
          '💰 **PAYE:** Rates and calculations\n'
          '📊 **VAT:** Rates and registration\n'
          '📅 **Deadlines:** Important dates\n'
          '💳 **Payments:** Methods and procedures\n'
          '📄 **Documents:** What you need\n'
          '⚠️ **Penalties:** What to avoid\n'
          '📞 **Contact:** How to reach TRA\n\n'
          'Just ask me anything about taxes in Tanzania!';
    }

    // ==================== FILE RETURN ====================
    if (message.contains('file') && (message.contains('return') || message.contains('tax'))) {
      return '📋 **How to File Your Tax Return**\n\n'
          'Follow these simple steps:\n\n'
          '1️⃣ **Prepare Documents:** Gather all income and deduction documents\n'
          '2️⃣ **Login:** Access your account\n'
          '3️⃣ **Select "File Return":** From the dashboard\n'
          '4️⃣ **Enter Details:** Fill in income and deductions\n'
          '5️⃣ **Upload Documents:** Attach supporting files\n'
          '6️⃣ **Review:** Check all information\n'
          '7️⃣ **Generate Report:** Create TRA report\n'
          '8️⃣ **Submit:** Send to TRA\n'
          '9️⃣ **Pay:** Complete payment\n'
          '🔟 **Download Receipt:** Save acknowledgment\n\n'
          'Shall I guide you through any specific step?';
    }

    // ==================== DEFAULT ====================
    return '🤔 I\'m not sure I understand. Let me try to help better.\n\n'
        'You can ask me about:\n\n'
        '• 📋 Filing your tax return\n'
        '• 💰 PAYE calculation\n'
        '• 📊 VAT rates\n'
        '• 📅 Deadlines\n'
        '• 💳 Payment methods\n'
        '• 📄 Required documents\n'
        '• ⚠️ Penalties\n'
        '• 📞 TRA contact\n\n'
        'Could you rephrase your question?';
  }

  static List<QuickReply>? _getQuickReplies(String message) {
    final lower = message.toLowerCase();
    
    // Show relevant quick replies based on context
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return QuickReply.taxTopics;
    }
    
    if (lower.contains('help') || lower.contains('assist') || lower.contains('guide')) {
      return QuickReply.helpTopics;
    }
    
    if (lower.contains('payment') || lower.contains('pay')) {
      return QuickReply.paymentMethods;
    }
    
    if (lower.contains('file') && lower.contains('return')) {
      return [
        QuickReply(label: '📋 Start Filing', value: 'How do I start filing?'),
        QuickReply(label: '📄 Documents', value: 'What documents do I need?'),
      ];
    }
    
    // Default quick replies
    return null;
  }
}