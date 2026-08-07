import 'dart:async';
import 'dart:io';

import 'package:fllama/fllama.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class LocalLlamaService {
  static const String _modelAssetPath =
      'assets/models/LFM2-5-230M-q4-0.gguf';
  static const String _modelFileName = 'LFM2-5-230M-q4-0.gguf';

  double? _contextId;
  Future<void>? _loadFuture;

  Future<String> _copyModelToAppStorage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_modelFileName');

    final assetData = await rootBundle.load(_modelAssetPath);
    final assetBytes = assetData.buffer.asUint8List();
    if (await file.exists() && await file.length() == assetBytes.length) {
      return file.path;
    }

    await file.writeAsBytes(assetBytes, flush: true);
    return file.path;
  }

  Future<void> loadModel() {
    return _loadFuture ??= _loadModel();
  }

  Future<void> _loadModel() async {
    if (_contextId != null) {
      return;
    }

    final fllama = Fllama.instance();
    if (fllama == null) {
      throw StateError('fllama is unavailable on this platform.');
    }

    final modelPath = await _copyModelToAppStorage();
    final result = await fllama.initContext(
      modelPath,
      nCtx: 4096,
      nBatch: 512,
      emitLoadProgress: true,
    );

    final rawContextId = result?['contextId']?.toString();
    final contextId = double.tryParse(rawContextId ?? '');
    if (contextId == null || contextId <= 0) {
      throw StateError('Local summary model failed to load.');
    }

    _contextId = contextId;
  }

  Future<String> complete(String prompt) async {
    await loadModel();

    final contextId = _contextId;
    final fllama = Fllama.instance();
    if (contextId == null || fllama == null) {
      throw StateError('Local summary model is not loaded.');
    }

    final result = await fllama.completion(
      contextId,
      prompt: _formatChatPrompt(prompt),
      temperature: 0.35,
      topP: 0.9,
      nPredict: 220,
      penaltyRepeat: 1.08,
      stop: const <String>[
        '<end_of_turn>',
        '<start_of_turn>',
      ],
    );

    final text = _extractCompletionText(result).trim();
    if (text.isEmpty) {
      throw StateError('Local summary model returned an empty summary.');
    }

    return text;
  }

  Future<void> dispose() async {
    final contextId = _contextId;
    if (contextId == null) {
      return;
    }

    _contextId = null;
    _loadFuture = null;
    await Fllama.instance()?.releaseContext(contextId);
  }

  String _formatChatPrompt(String prompt) {
    return '<start_of_turn>user\n$prompt<end_of_turn>\n<start_of_turn>model\n';
  }

  String _extractCompletionText(Map<Object?, dynamic>? result) {
    if (result == null) {
      return '';
    }

    const textKeys = <String>[
      'text',
      'content',
      'completion',
      'response',
      'result',
    ];

    for (final key in textKeys) {
      final value = result[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      if (value is Map<Object?, dynamic>) {
        final nested = _extractCompletionText(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return result.values
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' ')
        .trim();
  }
}
