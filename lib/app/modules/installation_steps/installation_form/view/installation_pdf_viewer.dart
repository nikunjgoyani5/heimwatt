import 'package:dio/dio.dart';
import 'package:heimwatt/app/utils/exports.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Loads the PDF once into memory (from [memoryBytes] or by downloading [networkUrl]),
/// shows progress until bytes are ready and until the viewer has finished opening the document,
/// then displays the preview.
class InstallationPdfViewer extends StatefulWidget {
  const InstallationPdfViewer({
    super.key,
    required this.networkUrl,
    this.memoryBytes,
    this.onDocumentLoaded,
  });

  final String networkUrl;
  final Uint8List? memoryBytes;
  final PdfDocumentLoadedCallback? onDocumentLoaded;

  @override
  State<InstallationPdfViewer> createState() => _InstallationPdfViewerState();
}

class _InstallationPdfViewerState extends State<InstallationPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfKey = GlobalKey();

  Uint8List? _bytes;
  Object? _loadError;
  bool _documentReady = false;

  /// 0.0–1.0 while downloading; null when indeterminate or not downloading.
  double? _downloadProgress;

  @override
  void initState() {
    super.initState();
    final cached = widget.memoryBytes;
    if (cached != null && cached.isNotEmpty) {
      _bytes = cached;
    } else {
      _downloadPdf();
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final dio = Dio();
      final response = await dio.get<Uint8List>(
        widget.networkUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          if (total > 0) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _bytes = response.data!;
        _downloadProgress = null;
      });
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    widget.onDocumentLoaded?.call(details);
    if (mounted) {
      setState(() => _documentReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Center(
        child: AppText(
          'Could not load PDF',
          style: AppTextStyle.medium14(color: AppColors.black002432),
        ),
      );
    }

    if (_bytes == null) {
      return _PdfLoadingPanel(
        title: AppStrings.loadingPdf,
        progress: _downloadProgress,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: SfPdfViewer.memory(
            _bytes!,
            key: _pdfKey,
            interactionMode: PdfInteractionMode.pan,
            enableTextSelection: false,
            canShowScrollHead: false,
            canShowScrollStatus: false,
            enableDoubleTapZooming: false,
            pageSpacing: 2,
            onDocumentLoaded: _onDocumentLoaded,
          ),
        ),
        if (!_documentReady)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.whiteColor,
              child: _PdfLoadingPanel(
                title: AppStrings.preparingPdfPreview,
                progress: null,
              ),
            ),
          ),
      ],
    );
  }
}

class _PdfLoadingPanel extends StatelessWidget {
  const _PdfLoadingPanel({
    required this.title,
    required this.progress,
  });

  final String title;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.greyADB9BD.withValues(alpha: 0.35),
                  color: AppColors.primaryColor,
                ),
              ),
              const Gap(20),
            ] else ...[
              const CircularProgressIndicator(),
              const Gap(20),
            ],
            AppText(
              title,
              style: AppTextStyle.medium16(color: AppColors.black002432),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
