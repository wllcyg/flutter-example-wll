import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/res/colors.dart';

/// Day 18 学习示例：Form 表单校验 Demo 页面
///
/// 核心要点：
/// 1. Form + GlobalKey<FormState> 是表单校验的三件套
/// 2. TextFormField 代替 TextField 参与校验
/// 3. Hooks 自动管理 Controller 生命周期（无需 dispose）
/// 4. autovalidateMode.onUserInteraction 实现"碰了才报错"
class FormDemoPage extends HookConsumerWidget {
  const FormDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ============================================
    // 1. 用 Hooks 创建所有控制器（自动管理生命周期）
    //    对标前端：const name = ref('')
    // ============================================
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final phoneCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final confirmCtrl = useTextEditingController();
    final bioCtrl = useTextEditingController();

    // 用户协议勾选状态
    final agreedToTerms = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('表单校验 Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          // ============================================
          // 2. Form 容器：用 GlobalKey 来引用它的状态
          //    对标前端：<el-form ref="formRef" :rules="rules">
          // ============================================
          key: formKey,
          // onUserInteraction = 用户开始输入后才开始校验
          // 不会一上来就满屏红色错误 ✅
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === 标题区 ===
              Text(
                '用户资料编辑',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '以下展示了 Flutter Form 表单校验的各种常见场景',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),

              // ============================================
              // 3. TextFormField：自带 validator 的输入框
              //    对标前端：<el-form-item prop="name" :rules="[...]">
              // ============================================

              // --- 昵称(必填 + 长度限制) ---
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: '昵称 *',
                  hintText: '请输入昵称 (2-20字符)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '昵称不能为空';
                  }
                  if (value.trim().length < 2) {
                    return '昵称至少 2 个字符';
                  }
                  if (value.trim().length > 20) {
                    return '昵称最多 20 个字符';
                  }
                  return null; // ✅ 返回 null 表示校验通过
                },
              ),
              SizedBox(height: 16.h),

              // --- 邮箱 (正则校验) ---
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: '邮箱 *',
                  hintText: '请输入邮箱地址',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '邮箱不能为空';
                  }
                  // 邮箱正则
                  final emailRegex =
                      RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return '请输入有效的邮箱格式';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // --- 手机号 (可选，但填了就要校验格式) ---
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  hintText: '选填',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  // 允许为空（选填）
                  if (value == null || value.isEmpty) return null;
                  // 但如果填了，就要校验格式
                  final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return '请输入有效的手机号';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // --- 密码 (复杂规则) ---
              TextFormField(
                controller: passwordCtrl,
                decoration: const InputDecoration(
                  labelText: '密码 *',
                  hintText: '至少 6 位，包含字母和数字',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '密码不能为空';
                  }
                  if (value.length < 6) {
                    return '密码至少 6 位';
                  }
                  if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                    return '密码需包含至少一个字母';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return '密码需包含至少一个数字';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // ============================================
              // 4. 跨字段校验：确认密码
              //    直接在 validator 中读取另一个 Controller 的值
              // ============================================
              TextFormField(
                controller: confirmCtrl,
                decoration: const InputDecoration(
                  labelText: '确认密码 *',
                  hintText: '请再次输入密码',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请确认密码';
                  }
                  // 🔥 跨字段校验：直接读取 passwordCtrl 的值
                  if (value != passwordCtrl.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // --- 个人简介 (多行文本 + 最大长度) ---
              TextFormField(
                controller: bioCtrl,
                decoration: const InputDecoration(
                  labelText: '个人简介',
                  hintText: '介绍一下自己吧（最多 200 字）',
                  prefixIcon: Icon(Icons.edit_note),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 16.h),

              // ============================================
              // 5. 自定义 FormField：Checkbox 也能参与表单校验！
              //    对标前端：自定义校验组件
              // ============================================
              FormField<bool>(
                initialValue: false,
                validator: (value) {
                  if (value != true) {
                    return '请阅读并同意用户协议';
                  }
                  return null;
                },
                builder: (FormFieldState<bool> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: agreedToTerms.value,
                            onChanged: (val) {
                              agreedToTerms.value = val ?? false;
                              state.didChange(val); // 通知 FormField 值变了
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                agreedToTerms.value = !agreedToTerms.value;
                                state.didChange(agreedToTerms.value);
                              },
                              child: Text(
                                '我已阅读并同意《用户协议》和《隐私政策》',
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 显示校验错误信息
                      if (state.hasError)
                        Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              SizedBox(height: 24.h),

              // ============================================
              // 6. 提交按钮：一键校验全部字段
              //    对标前端：formRef.validate()
              // ============================================
              FilledButton.icon(
                onPressed: () {
                  // 🔥 一键校验！和前端的 formRef.validate() 一样爽
                  if (formKey.currentState!.validate()) {
                    // 所有字段通过校验
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✅ 校验通过，表单数据已收集！'),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    // 收集表单数据
                    final formData = {
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'bio': bioCtrl.text.trim(),
                    };
                    debugPrint('表单数据: $formData');
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    '提 交',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // === 重置按钮 ===
              OutlinedButton.icon(
                onPressed: () {
                  // 🔥 一键重置！和前端的 formRef.resetFields() 一样
                  formKey.currentState!.reset();
                  nameCtrl.clear();
                  emailCtrl.clear();
                  phoneCtrl.clear();
                  passwordCtrl.clear();
                  confirmCtrl.clear();
                  bioCtrl.clear();
                  agreedToTerms.value = false;
                },
                icon: const Icon(Icons.refresh),
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    '重 置',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
