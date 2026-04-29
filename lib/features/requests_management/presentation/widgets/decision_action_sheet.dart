import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/admin_widgets.dart';

/// Result returned from the decision sheet — captures the admin's choice and
/// any optional notes they supplied.
class DecisionResult {
  /// `'approve'` or `'reject'`
  final String decision;
  final String? notes;
  const DecisionResult({required this.decision, this.notes});

  bool get isApprove => decision == 'approve';
  bool get isReject => decision == 'reject';
}

/// Open a unified bottom-sheet for taking a decision on a request.
///
/// Used by both Employee Requests and Leave Requests detail screens.
/// Returns `null` if the user dismissed the sheet without confirming.
Future<DecisionResult?> showDecisionSheet(
  BuildContext context, {
  required String decision, // 'approve' | 'reject'
  required String requestSummary, // e.g. "طلب سلفة — laptop"
  required String employeeName,
  required bool notesRequired,
}) {
  return showModalBottomSheet<DecisionResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DecisionSheet(
      decision: decision,
      requestSummary: requestSummary,
      employeeName: employeeName,
      notesRequired: notesRequired,
    ),
  );
}

class _DecisionSheet extends StatefulWidget {
  final String decision;
  final String requestSummary;
  final String employeeName;
  final bool notesRequired;
  const _DecisionSheet({
    required this.decision,
    required this.requestSummary,
    required this.employeeName,
    required this.notesRequired,
  });
  @override
  State<_DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends State<_DecisionSheet> {
  final _notesCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  bool get _isApprove => widget.decision == 'approve';

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final notes = _notesCtrl.text.trim();
    if (widget.notesRequired && notes.isEmpty) {
      setState(() => _error = 'Notes required'.tr(context));
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    Navigator.pop(
      context,
      DecisionResult(
        decision: widget.decision,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final accent = _isApprove ? AppColors.success : AppColors.error;
    final icon = _isApprove
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final title = _isApprove
        ? 'Approve request?'.tr(context)
        : 'Reject request?'.tr(context);
    final notesLabel = _isApprove
        ? 'Notes (optional)'.tr(context)
        : 'Reason for rejection'.tr(context);
    final notesHint = _isApprove
        ? 'optional'.tr(context)
        : 'Required'.tr(context);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.g300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            // Header row
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 2),
                    Text(widget.employeeName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: c.textMuted,
                        )),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Request summary card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.g300.withOpacity(0.5)),
              ),
              child: Text(widget.requestSummary,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5,
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            const SizedBox(height: 14),
            // Notes field
            Text(notesLabel,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.g500,
                )),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              autofocus: !_isApprove,
              decoration: InputDecoration(
                hintText: notesHint,
                hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5,
                    color: AppColors.g400),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.g300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5,
                          color: AppColors.error,
                        )),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            // Action buttons
            Row(children: [
              Expanded(
                child: OutlineBtn(
                  text: 'Cancel'.tr(context),
                  onTap: _submitting ? null : () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _isApprove
                    ? _SuccessBtn(
                        text: 'Approve'.tr(context),
                        onTap: _submitting ? null : _submit,
                      )
                    : _DangerBtn(
                        text: 'Reject'.tr(context),
                        onTap: _submitting ? null : _submit,
                      ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SuccessBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _SuccessBtn({required this.text, this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check_rounded, size: 18),
        label: Text(text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w800,
            )),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _DangerBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _DangerBtn({required this.text, this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.close_rounded, size: 18),
        label: Text(text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w800,
            )),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11)),
          elevation: 0,
        ),
      ),
    );
  }
}
