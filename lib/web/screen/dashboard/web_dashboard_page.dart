import 'package:fluent_ui/fluent_ui.dart';

class WebDashboardPage extends StatefulWidget {
  const WebDashboardPage({super.key});

  @override
  State<WebDashboardPage> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends State<WebDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text(
            'Dashboard Warnet',
            style: FluentTheme.of(context).typography.title,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        Text(
                          'Selamat Datang di Dashboard Warnet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pantau transaksi dan aktivitas warnet Anda dengan mudah.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Add your dashboard content here
                  ],
                ),
              ),
            ),
          ),
        ]);
  }
}
