import 'package:saycheese_mobile/src/models/payment_intent_response.dart';
import 'package:saycheese_mobile/src/models/stripe_custom_response.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';

class StripeClient {
  StripeClient._privateConstructor();
  static final StripeClient _intance = StripeClient._privateConstructor();
  factory StripeClient() => _intance;

  final String _paymentApiUrl = "https://api.stripe.com/v1/payment_intents";
  static final String _secretKey =
      "sk_test_51I9t3CLh1eQyBREO9DDe7Bd4V8E3noe97lLN93gcqqXVaGYGtpNr9PkuKSDgf3XiTI2nZDftzjZt6RkpXJjAiabO00ZlwpIX8x";
  final String _apiKey =
      "pk_test_51I9t3CLh1eQyBREOZvhduZ2NZ7aILlcMKpG68qVqzqb90yBMDV5HBN0dXWaPHbuBtZl3zcDghnz5uf81JRCAVJyf00Drpbb9iH";

  final headerOptions = new Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {'Authorization': 'Bearer ${StripeClient._secretKey}'});

  void init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey: this._apiKey,
        androidPayMode: 'test',
        merchantId: 'test'));
  }

  Future<StripeCustomResponse> paymentWithNewCard(
      {@required String amount, @required String currency}) async {
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      final resp = await this._makePayment(
          amount: amount, currency: currency, paymentMethod: paymentMethod);
      return resp;
    } catch (e) {
      print(e.toString());
      return StripeCustomResponse(success: false, message: e.toString());
    }
  }

  Future<StripeCustomResponse> _makePayment(
      {@required String amount,
      @required String currency,
      @required PaymentMethod paymentMethod}) async {
    try {
      // Crear el intent
      final paymentIntent =
          await this._createPaymentIntent(amount: amount, currency: currency);
      // Confirm payment
      final paymentResult = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              clientSecret: paymentIntent.clientSecret,
              paymentMethodId: paymentMethod.id));

      if (paymentResult.status == 'succeeded') {
        return StripeCustomResponse(success: true);
      } else {
        return StripeCustomResponse(
            success: false,
            message:
                'Error in method _makePayment(String amount,String currency, PaymentMethod paymentMethod): ${paymentResult.status}');
      }
    } catch (e) {
      print(e.toString());
      return StripeCustomResponse(success: false, message: e.toString());
    }
  }

  Future<PaymentIntentResponse> _createPaymentIntent(
      {@required String amount, @required String currency}) async {
    try {
      final dio = new Dio();
      final data = {'amount': amount, 'currency': currency};
      final resp =
          await dio.post(_paymentApiUrl, data: data, options: headerOptions);
      return PaymentIntentResponse.fromJson(resp.data);
    } catch (e) {
      print("Ocurrió un error con el payment intent response");
      return PaymentIntentResponse(status: "400");
    }
  }
}
