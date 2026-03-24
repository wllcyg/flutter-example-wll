import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("账号安全"), centerTitle: true),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("修改密码"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to Change Password Page or show Dialog
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("注销账号"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Show Delete Account Dialog
                },
              ),
            ],
          ),
        ));
  }
}
