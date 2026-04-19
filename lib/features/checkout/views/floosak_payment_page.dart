import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/checkout/controllers/checkout_controller.dart';
import 'package:bytore/features/checkout/models/floosak_payment_attempt_model.dart';
import 'package:bytore/features/orders/models/order_model.dart';

class FloosakPaymentPage extends GetView<CheckoutController> {
  const FloosakPaymentPage({super.key});

  void _initializeFromArguments() {
    final args = Get.arguments;
    if (args is! Map) return;

    final receivedOrder = args['order'];
    final receivedAttempt = args['initialAttempt'];

    if (receivedOrder is OrderModel &&
        receivedAttempt is FloosakPaymentAttemptModel) {
      controller.initializeFloosakPayment(receivedOrder, receivedAttempt);
    }
  }

  Future<void> _confirmOtp() async {
    final otp = controller.floosakOtpController.text.trim();
    await controller.confirmActiveFloosakOtp(otp);
  }

  @override
  Widget build(BuildContext context) {
    _initializeFromArguments();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        final currentOrder = controller.activeFloosakOrder.value;
        final currentAttempt = controller.activeFloosakAttempt.value;
        final errorMessage = controller.floosakErrorMessage.value;
        final statusMessage = controller.floosakStatusMessage.value;

        if (currentOrder == null || currentAttempt == null) {
          return const Center(child: Text("تعذر تحميل بيانات عملية الدفع"));
        }

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildModernProgress(),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildStatusHeader(currentAttempt),
                    const SizedBox(height: 24),
                    _buildSummaryCard(currentOrder, currentAttempt),
                    const SizedBox(height: 24),
                    if (currentAttempt.isPendingOtp) _buildOtpCard(),
                    if (currentAttempt.isProcessing) _buildProcessingCard(),
                    if (currentAttempt.isFailed) _buildFailureCard(),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorBox(errorMessage),
                    ],
                    if (statusMessage != null && !currentAttempt.isFailed) ...[
                      const SizedBox(height: 16),
                      _buildInfoBox(statusMessage),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        "دفع فلوسك",
        style: TextStyle(
          color: kTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildModernProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepNode(Icons.check_circle_rounded, "العنوان", false, isDone: true),
          _stepLine(true),
          _stepNode(Icons.check_circle_rounded, "الدفع", false, isDone: true),
          _stepLine(true),
          _stepNode(Icons.assignment_turned_in_rounded, "التأكيد", true),
        ],
      ),
    );
  }

  Widget _stepNode(
    IconData icon,
    String label,
    bool isActive, {
    bool isDone = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? kPrimaryColor
                : (isDone ? Colors.white : kBgColor),
            shape: BoxShape.circle,
            border: Border.all(
              color: (isActive || isDone)
                  ? kPrimaryColor
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Icon(
            isDone ? Icons.check : icon,
            color: isActive
                ? Colors.white
                : (isDone ? kPrimaryColor : Colors.grey.shade400),
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: (isActive || isDone) ? kTextColor : Colors.grey,
            fontSize: 11,
            fontWeight: (isActive || isDone)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22, left: 10, right: 10),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(FloosakPaymentAttemptModel currentAttempt) {
    final isFailed = currentAttempt.isFailed;
    final isProcessingState = currentAttempt.isProcessing;

    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: isFailed
                ? Colors.red.withValues(alpha: 0.08)
                : kPrimaryColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFailed
                ? Icons.error_rounded
                : isProcessingState
                ? Icons.hourglass_top_rounded
                : Icons.lock_rounded,
            color: isFailed ? Colors.redAccent : kPrimaryColor,
            size: 44,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          isFailed
              ? "تعذر إكمال الدفع"
              : isProcessingState
              ? "جاري التحقق من الدفع"
              : "أدخل رمز تحقق فلوسك",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isFailed
              ? "يمكنك الرجوع لاختيار طريقة دفع أخرى أو إعادة المحاولة."
              : isProcessingState
              ? "سنقوم بتحديث الحالة تلقائياً عند اكتمال المعالجة."
              : "استخدم الرمز الذي يصلك من فلوسك لإتمام عملية الدفع.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kTextLightColor,
            height: 1.6,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    OrderModel currentOrder,
    FloosakPaymentAttemptModel currentAttempt,
  ) {
    final amount = currentAttempt.amount ?? currentOrder.totalPrice;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kBgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _summaryRow("رقم الطلب", "#${currentOrder.id}"),
          const SizedBox(height: 10),
          _summaryRow("رقم عملية الدفع", "#${currentAttempt.paymentAttemptId}"),
          const SizedBox(height: 10),
          _summaryRow("المبلغ", "${amount.toStringAsFixed(2)} ر.ي"),
          if (currentAttempt.gatewayReferenceId != null) ...[
            const SizedBox(height: 10),
            _summaryRow("مرجع فلوسك", currentAttempt.gatewayReferenceId!),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: kTextLightColor, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: kTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    final isConfirming = controller.isConfirmingFloosak.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.floosakOtpController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            onSubmitted: (_) {
              if (!isConfirming) _confirmOtp();
            },
            decoration: InputDecoration(
              hintText: "رمز التحقق",
              filled: true,
              fillColor: kBgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isConfirming ? null : _confirmOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: kPrimaryColor.withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isConfirming
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "تأكيد الدفع",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard() {
    final isPolling = controller.isPollingFloosak.value;
    final pollInFlight = controller.isFloosakPollInFlight.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: kPrimaryColor),
          const SizedBox(height: 16),
          Text(
            isPolling
                ? "يتم التحقق من حالة الدفع تلقائياً..."
                : "بانتظار تحديث حالة الدفع...",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: pollInFlight
                ? null
                : () => controller.refreshActiveFloosakAttempt(),
            child: const Text("تحديث الحالة الآن"),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildErrorBox("لم تكتمل عملية الدفع عبر فلوسك."),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimaryColor,
            side: const BorderSide(color: kPrimaryColor),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text("العودة للدفع وإعادة المحاولة"),
        ),
      ],
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoBox(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
