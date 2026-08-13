import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Política de Privacidade', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Política de Privacidade - Rastros Snake',
              style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Sua privacidade é importante para nós. Esta Política de Privacidade explica como o aplicativo "Rastros Snake" trata as informações dos usuários.\n\n'
              '1. Coleta de Dados Locais:\n'
              'O jogo salva localmente no dispositivo dados de progresso, recordes de pontuação e preferências de configuração (como som e skin selecionada).\n\n'
              '2. Anúncios e Publicidade de Terceiros:\n'
              'Este aplicativo exibe anúncios fornecidos por redes de publicidade de parceiros (como Google AdMob). Essas redes podem coletar e utilizar identificadores anônimos do dispositivo (como ID de publicidade), dados de uso e localização aproximada para exibir anúncios personalizados ou relevantes para você.\n\n'
              '3. Serviços de Terceiros:\n'
              'Os parceiros de publicidade possuem suas próprias políticas de privacidade sobre como processam os dados. Recomendamos consultar a política de privacidade do provedor de anúncios para entender suas práticas.\n\n'
              '4. Alterações nesta Política:\n'
              'Podemos atualizar nossa Política de Privacidade periodicamente. Quaisquer alterações entram em vigor imediatamente após a publicação nesta tela.\n\n'
              '5. Contato:\n'
              'Em caso de dúvidas sobre esta política de privacidade ou o uso de dados, entre em contato através do suporte do aplicativo.',
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
