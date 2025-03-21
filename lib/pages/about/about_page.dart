import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          const Text(
            'Easy Timer',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '版本: 0.1.0',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            '开发者信息',
            [
              '作者: sqmw',
              InkWell(
                onTap: () => _launchUrl('https://github.com/sqmw/'),
                child: Text(
                  'GitHub: https://github.com/sqmw/',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[200],
                    decoration: TextDecoration.underline,
                    height: 1.5,
                  ),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => _launchUrl('mailto:sq17127401791@gmail.com'),
                    child: Text(
                      'Email: sq17127401791@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[200],
                        decoration: TextDecoration.underline,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: 'sq17127401791@gmail.com'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('邮箱已复制到剪贴板'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '应用介绍',
            [
              '这是一个功能强大的 Flutter 计时器应用，提供优雅的界面和丰富的计时功能。',
              '支持多种计时显示方式，包括经典数字显示和图形化显示。',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '主要功能',
            [
              '• 支持创建和管理多个计时器',
              '• 自定义多个时间段设置',
              '• 灵活的计时器命名和分类',
              '• 支持计时器的暂停、继续和重置',
              '• 每个计时器结束都可以设置不同的铃声',
              '• 每个计时器支持自动开始和手动开始模式',
              '• 支持数字和图形化两种显示方式',
              '• 提供沙漏和饼图两种图形化样式',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '问题反馈',
            [
              '如果您在使用过程中遇到任何问题，或有任何建议，欢迎通过以下方式反馈：',
              '• 在 GitHub 上提交 Issue',
              '• 发送邮件至开发者邮箱',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '使用帮助',
            [
              '详细的使用说明和帮助文档，请访问我们的 GitHub 仓库查看。',
            ],
          ),
          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} Easy Timer. All rights reserved.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> contents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...contents.map((content) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: content is String
                  ? Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    )
                  : content,
            )),
      ],
    );
  }
}