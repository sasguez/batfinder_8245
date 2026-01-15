import 'package:dio/dio.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Dio _dio = Dio();

  final String _supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  final String _anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  // ==================== SMS NOTIFICATIONS ====================

  /// Sends an SMS notification using Twilio via Supabase Edge Function
  ///
  /// [phoneNumber] - Recipient phone number (format: +521234567890)
  /// [message] - Message content to send
  ///
  /// Returns true if SMS was sent successfully
  Future<bool> sendSmsNotification({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final url = '$_supabaseUrl/functions/v1/send-sms';

      final response = await _dio.post(
        url,
        data: {'to': phoneNumber, 'message': message},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_anonKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] ?? false;
      }

      return false;
    } catch (error) {
      print('SMS notification error: $error');
      return false;
    }
  }

  /// Sends emergency alert to authority users
  ///
  /// [incidentTitle] - Brief title of the incident
  /// [location] - Location description
  /// [severity] - Severity level (low, medium, high, critical)
  Future<void> sendEmergencyAlert({
    required String incidentTitle,
    required String location,
    required String severity,
  }) async {
    try {
      // In production, fetch authority phone numbers from database
      // For MVP, this is a placeholder implementation
      final message =
          '🚨 ALERTA DE SEGURIDAD\n'
          'Incidente: $incidentTitle\n'
          'Ubicación: $location\n'
          'Severidad: $severity\n'
          'Responder a través de BatFinder';

      // This would be called with actual authority phone numbers
      // await sendSmsNotification(phoneNumber: authorityPhone, message: message);

      print('Emergency alert prepared: $message');
    } catch (error) {
      print('Emergency alert error: $error');
    }
  }

  /// Sends incident status update notification
  ///
  /// [phoneNumber] - Reporter's phone number
  /// [incidentTitle] - Title of the incident
  /// [newStatus] - New status of the incident
  Future<bool> sendIncidentUpdateNotification({
    required String phoneNumber,
    required String incidentTitle,
    required String newStatus,
  }) async {
    final message =
        'Actualización de incidente: "$incidentTitle" - Estado: $newStatus';
    return await sendSmsNotification(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// Sends verification code for phone number verification
  ///
  /// [phoneNumber] - Phone number to verify
  /// [verificationCode] - 6-digit verification code
  Future<bool> sendVerificationCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    final message =
        'Tu código de verificación BatFinder es: $verificationCode\n'
        'Este código expira en 10 minutos.';
    return await sendSmsNotification(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  // ==================== EMAIL NOTIFICATIONS ====================

  /// Sends an email notification using Resend via Supabase Edge Function
  ///
  /// [email] - Recipient email address
  /// [subject] - Email subject line
  /// [html] - HTML content of the email
  /// [type] - Email type (incident_report, verification_update, safety_announcement)
  ///
  /// Returns true if email was sent successfully
  Future<bool> sendEmailNotification({
    required String email,
    required String subject,
    required String html,
    String type = 'notification',
  }) async {
    try {
      final url = '$_supabaseUrl/functions/v1/send-email';

      final response = await _dio.post(
        url,
        data: {'to': email, 'subject': subject, 'html': html, 'type': type},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_anonKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] ?? false;
      }

      return false;
    } catch (error) {
      print('Email notification error: $error');
      return false;
    }
  }

  /// Sends incident report confirmation email
  ///
  /// [email] - Reporter's email address
  /// [incidentTitle] - Title of the reported incident
  /// [incidentId] - Unique incident identifier
  /// [location] - Location of the incident
  /// [severity] - Severity level
  Future<bool> sendIncidentReportEmail({
    required String email,
    required String incidentTitle,
    required String incidentId,
    required String location,
    required String severity,
  }) async {
    final subject = '✅ Reporte de Incidente Recibido - BatFinder';
    final html =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
          .info-box { background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #667eea; }
          .severity-${severity.toLowerCase()} { border-left-color: ${_getSeverityColor(severity)}; }
          .footer { text-align: center; padding: 20px; color: #6b7280; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🛡️ BatFinder</h1>
            <p>Reporte de Incidente Confirmado</p>
          </div>
          <div class="content">
            <h2>¡Gracias por tu reporte!</h2>
            <p>Tu reporte de incidente ha sido recibido y está siendo revisado por nuestro equipo.</p>
            
            <div class="info-box severity-${severity.toLowerCase()}">
              <h3>📋 Detalles del Reporte</h3>
              <p><strong>Incidente:</strong> $incidentTitle</p>
              <p><strong>ID de Referencia:</strong> $incidentId</p>
              <p><strong>Ubicación:</strong> $location</p>
              <p><strong>Severidad:</strong> ${_getSeverityLabel(severity)}</p>
            </div>
            
            <p>Recibirás notificaciones cuando se actualice el estado de tu reporte.</p>
            <p>Puedes revisar el progreso en la aplicación BatFinder.</p>
          </div>
          <div class="footer">
            <p>BatFinder - Comunidad Segura</p>
            <p>Este es un email automático, por favor no responder.</p>
          </div>
        </div>
      </body>
      </html>
    ''';

    return await sendEmailNotification(
      email: email,
      subject: subject,
      html: html,
      type: 'incident_report',
    );
  }

  /// Sends verification update email
  ///
  /// [email] - User's email address
  /// [fullName] - User's full name
  /// [verificationStatus] - New verification status (verified, rejected)
  /// [message] - Optional custom message
  Future<bool> sendVerificationUpdateEmail({
    required String email,
    required String fullName,
    required String verificationStatus,
    String? message,
  }) async {
    final isVerified = verificationStatus.toLowerCase() == 'verified';
    final subject = isVerified
        ? '✅ Cuenta Verificada - BatFinder'
        : '❌ Actualización de Verificación - BatFinder';

    final html =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: ${isVerified ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)'}; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
          .badge { display: inline-block; padding: 8px 16px; border-radius: 20px; font-weight: bold; margin: 15px 0; }
          .verified { background: #d1fae5; color: #065f46; }
          .rejected { background: #fee2e2; color: #991b1b; }
          .footer { text-align: center; padding: 20px; color: #6b7280; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🛡️ BatFinder</h1>
            <p>${isVerified ? '¡Verificación Completada!' : 'Actualización de Verificación'}</p>
          </div>
          <div class="content">
            <h2>Hola, $fullName</h2>
            <p>Tu estado de verificación ha sido actualizado:</p>
            
            <div style="text-align: center;">
              <span class="badge ${isVerified ? 'verified' : 'rejected'}">
                ${isVerified ? '✅ VERIFICADO' : '❌ REQUIERE REVISIÓN'}
              </span>
            </div>
            
            ${isVerified ? '''
              <p>¡Felicidades! Tu cuenta ha sido verificada exitosamente.</p>
              <p>Ahora tienes acceso completo a todas las funciones de BatFinder.</p>
            ''' : '''
              <p>Tu solicitud de verificación requiere atención adicional.</p>
              ${message != null ? '<p><strong>Mensaje:</strong> $message</p>' : ''}
              <p>Por favor, revisa tu documentación y vuelve a intentarlo.</p>
            '''}
          </div>
          <div class="footer">
            <p>BatFinder - Comunidad Segura</p>
            <p>Este es un email automático, por favor no responder.</p>
          </div>
        </div>
      </body>
      </html>
    ''';

    return await sendEmailNotification(
      email: email,
      subject: subject,
      html: html,
      type: 'verification_update',
    );
  }

  /// Sends community safety announcement email
  ///
  /// [email] - Recipient's email address
  /// [announcementTitle] - Title of the announcement
  /// [announcementContent] - Content of the announcement
  /// [severity] - Severity level (low, medium, high, critical)
  Future<bool> sendSafetyAnnouncementEmail({
    required String email,
    required String announcementTitle,
    required String announcementContent,
    required String severity,
  }) async {
    final subject = '🚨 Alerta de Seguridad - BatFinder';
    final html =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: ${_getSeverityGradient(severity)}; color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
          .alert-box { background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid ${_getSeverityColor(severity)}; }
          .severity-badge { display: inline-block; padding: 6px 12px; border-radius: 15px; font-weight: bold; font-size: 14px; background: ${_getSeverityColor(severity)}; color: white; }
          .footer { text-align: center; padding: 20px; color: #6b7280; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🛡️ BatFinder</h1>
            <p>Alerta de Seguridad Comunitaria</p>
          </div>
          <div class="content">
            <div class="alert-box">
              <span class="severity-badge">${_getSeverityLabel(severity).toUpperCase()}</span>
              <h2>$announcementTitle</h2>
              <p>$announcementContent</p>
            </div>
            
            <p><strong>Recomendaciones:</strong></p>
            <ul>
              <li>Mantente alerta en tu área</li>
              <li>Comparte esta información con tu comunidad</li>
              <li>Reporta cualquier actividad sospechosa</li>
            </ul>
            
            <p>Para más información, revisa la aplicación BatFinder.</p>
          </div>
          <div class="footer">
            <p>BatFinder - Comunidad Segura</p>
            <p>Este es un email automático, por favor no responder.</p>
          </div>
        </div>
      </body>
      </html>
    ''';

    return await sendEmailNotification(
      email: email,
      subject: subject,
      html: html,
      type: 'safety_announcement',
    );
  }

  // ==================== HELPER METHODS ====================

  String _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return '#dc2626';
      case 'high':
        return '#ea580c';
      case 'medium':
        return '#f59e0b';
      case 'low':
        return '#10b981';
      default:
        return '#6b7280';
    }
  }

  String _getSeverityGradient(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'linear-gradient(135deg, #dc2626 0%, #991b1b 100%)';
      case 'high':
        return 'linear-gradient(135deg, #ea580c 0%, #c2410c 100%)';
      case 'medium':
        return 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)';
      case 'low':
        return 'linear-gradient(135deg, #10b981 0%, #059669 100%)';
      default:
        return 'linear-gradient(135deg, #6b7280 0%, #4b5563 100%)';
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'Crítico';
      case 'high':
        return 'Alto';
      case 'medium':
        return 'Medio';
      case 'low':
        return 'Bajo';
      default:
        return 'Desconocido';
    }
  }
}
