import 'localized_text_model.dart';
import 'dart:math';

import 'package:flutter/material.dart';

const Map<CardType, String> CardTypeIconAsset = <CardType, String>{
  CardType.visa: 'icons/visa.png',
  CardType.americanExpress: 'icons/amex.png',
  CardType.mastercard: 'icons/mastercard.png',
  CardType.discover: 'icons/discover.png',
};

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget({
    Key? key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.showBackView,
    this.animationDuration = const Duration(milliseconds: 500),
    this.height,
    this.width,
    this.textStyle,
    this.cardName,
    this.cardBgColor = const Color(0xff1b447b),
    this.obscureCardNumber = true,
    this.obscureCardCvv = true,
    this.labelCardHolder = 'Nome completo',
    this.labelExpiredDate = 'MM/YY',
    this.cardType,
  }) : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final Function(String)? cardName;
  final String cardHolderName;
  final String cvvCode;
  final TextStyle? textStyle;
  final Color cardBgColor;
  final bool showBackView;
  final Duration animationDuration;
  final double? height;
  final double? width;
  final bool obscureCardNumber;
  final bool obscureCardCvv;

  final String labelCardHolder;
  final String labelExpiredDate;

  final CardType? cardType;

  @override
  _CreditCardWidgetState createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;
  late Gradient backgroundGradientColor;

  bool isAmex = false;

  @override
  void initState() {
    super.initState();

    ///initialize the animation controller
    controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    backgroundGradientColor = LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      // Add one stop for each color. Stops should increase from 0 to 1
      stops: const <double>[0.1, 0.4, 0.7, 0.9],
      colors: <Color>[
        widget.cardBgColor.withOpacity(1),
        widget.cardBgColor.withOpacity(0.97),
        widget.cardBgColor.withOpacity(0.90),
        widget.cardBgColor.withOpacity(0.86),
      ],
    );

    ///Initialize the Front to back rotation tween sequence.
    _frontRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);

    _backRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final Orientation orientation = MediaQuery.of(context).orientation;
    Future.delayed(Duration.zero, () async {
      widget.cardName!(getCardTypeName(widget.cardNumber));
    });

    ///
    /// If uer adds CVV then toggle the card from front to back..
    /// controller forward starts animation and shows back layout.
    /// controller reverse starts animation and shows front layout.
    ///
    if (widget.showBackView) {
      controller.forward();
    } else {
      controller.reverse();
    }

    return Stack(
      children: <Widget>[
        AnimationCard(
          animation: _frontRotation,
          child: buildFrontContainer(width, height, context, orientation),
        ),
        AnimationCard(
          animation: _backRotation,
          child: buildBackContainer(width, height, context, orientation),
        ),
      ],
    );
  }

  ///
  /// Builds a back container containing cvv
  ///
  Container buildBackContainer(
    double width,
    double height,
    BuildContext context,
    Orientation orientation,
  ) {
    final TextStyle defaultTextStyle =
        Theme.of(context).textTheme.headline6!.merge(
              const TextStyle(
                color: Colors.black,
                fontFamily: 'halter',
                fontSize: 16,
                package: 'flutter_credit_card_brazilian',
              ),
            );

    final String cvv = widget.obscureCardCvv
        ? widget.cvvCode.replaceAll(RegExp(r'\d'), '*')
        : widget.cvvCode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: backgroundGradientColor,
      ),
      margin: const EdgeInsets.all(16),
      width: widget.width ?? width,
      height: widget.height ??
          (orientation == Orientation.portrait ? height / 4 : height / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              height: 48,
              color: Colors.black,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: Container(
                      height: 48,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          widget.cvvCode.isEmpty
                              ? isAmex
                                  ? 'XXXX'
                                  : 'XXX'
                              : cvv,
                          maxLines: 1,
                          style: widget.textStyle ?? defaultTextStyle,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: widget.cardType != null
                    ? getCardTypeImage(widget.cardType)
                    : getCardTypeIcon(widget.cardNumber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  /// Builds a front container containing
  /// Card number, Exp. year and Card holder name
  ///
  Container buildFrontContainer(
    double width,
    double height,
    BuildContext context,
    Orientation orientation,
  ) {
    final TextStyle defaultTextStyle =
        Theme.of(context).textTheme.headline6!.merge(
              const TextStyle(
                color: Colors.white,
                fontFamily: 'halter',
                fontSize: 16,
                package: 'flutter_credit_card_brazilian',
              ),
            );

    final String number = widget.obscureCardNumber
        ? widget.cardNumber.replaceAll(RegExp(r'(?<=.{4})\d(?=.{4})'), '*')
        : widget.cardNumber;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: backgroundGradientColor,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
          ),
        ],
      ),
      width: widget.width ?? width,
      height: widget.height ??
          (orientation == Orientation.portrait ? height / 4 : height / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: widget.cardType != null
                  ? getCardTypeImage(widget.cardType)
                  : getCardTypeIcon(widget.cardNumber),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                widget.cardNumber.isEmpty ? 'XXXX XXXX XXXX XXXX' : number,
                style: widget.textStyle ?? defaultTextStyle,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                widget.expiryDate.isEmpty
                    ? widget.labelExpiredDate
                    : widget.expiryDate,
                style: widget.textStyle ?? defaultTextStyle,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                widget.cardHolderName.isEmpty
                    ? widget.labelCardHolder
                    : widget.cardHolderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: widget.textStyle ?? defaultTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Credit Card prefix patterns as of March 2019
  /// A [List<String>] represents a range.
  /// i.e. ['51', '55'] represents the range of cards starting with '51' to those starting with '55'
  Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.aura: <List<String>>{
      <String>['50'],
    },
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.cabal: <List<String>>{
      <String>['60'],
      <String>['99'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
    CardType.dinersclub: <List<String>>{
      <String>['30'],
      <String>['300', '305'],
      <String>['36'],
      <String>['38'],
      <String>['39'],
    },
    CardType.jcb: <List<String>>{
      <String>['3506', '3589'],
      <String>['2131'],
      <String>['1800'],
    },
    CardType.elo: <List<String>>{
      <String>['4011'],
      <String>['401178'],
      <String>['401179'],
      <String>['438935'],
      <String>['457631'],
      <String>['457632'],
      <String>['431274'],
      <String>['451416'],
      <String>['457393'],
      <String>['504175'],
      <String>['506699', '506778'],
      <String>['509000', '509999'],
      <String>['627780'],
      <String>['636297'],
      <String>['636368'],
      <String>['650031', '650033'],
      <String>['650035', '650051'],
      <String>['650405', '650439'],
      <String>['650485', '650538'],
      <String>['650541', '650598'],
      <String>['650700', '650718'],
      <String>['650720', '650727'],
      <String>['650901', '650978'],
      <String>['651652', '651679'],
      <String>['655000', '655019'],
      <String>['655021', '655058'],
      <String>['6555'],
    },
    CardType.hiper: <List<String>>{
      <String>['637095'],
      <String>['637568'],
      <String>['637599'],
      <String>['637609'],
      <String>['637612'],
    },
    CardType.assomise: <List<String>>{
      <String>['639595'],
      <String>['608732'],
    },
    CardType.fortbrasil: <List<String>>{
      <String>['628167'],
    },
    CardType.sorocred: <List<String>>{
      <String>['627892'],
      <String>['606014'],
      <String>['636414'],
    },
    CardType.realcard: <List<String>>{
      <String>['637176'],
    },
    CardType.hipercard: <List<String>>{
      <String>['6062'],
      <String>['384100'],
      <String>['384140'],
      <String>['384160'],
    },
    CardType.credishop: <List<String>>{
      <String>['603136'],
      <String>['603134'],
      <String>['603135'],
    },
    CardType.banese: <List<String>>{
      <String>['6366'],
      <String>['6361'],
      <String>['6374']
    }
  };

  /// This function determines the Credit Card type based on the cardPatterns
  /// and returns it.
  CardType detectCCType(String cardNumber) {
    //Default card type is other
    CardType cardType = CardType.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    cardNumPatterns.forEach(
      (CardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          String ccPatternStr =
              cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }

  Widget getCardTypeImage(CardType? cardType) => Image.asset(
        CardTypeIconAsset[cardType]!,
        height: 48,
        width: 48,
        package: 'flutter_credit_card_brazilian',
      );

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  Widget getCardTypeIcon(String cardNumber) {
    Widget icon;
    switch (detectCCType(cardNumber)) {
      case CardType.visa:
        icon = Image.asset(
          'icons/visa.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.americanExpress:
        icon = Image.asset(
          'icons/amex.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = true;
        break;

      case CardType.mastercard:
        icon = Image.asset(
          'icons/mastercard.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.discover:
        icon = Image.asset(
          'icons/discover.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.assomise:
        icon = Image.asset(
          'icons/assomise.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.aura:
        icon = Image.asset(
          'icons/aura.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.dinersclub:
        icon = Image.asset(
          'icons/dinersclub.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.fortbrasil:
        icon = Image.asset(
          'icons/fortbrasil.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.elo:
        icon = Image.asset(
          'icons/elo.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.hiper:
        icon = Image.asset(
          'icons/hiper.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.hipercard:
        icon = Image.asset(
          'icons/hipercard.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.jcb:
        icon = Image.asset(
          'icons/jcb.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.sorocred:
        icon = Image.asset(
          'icons/sorocred.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.realcard:
        icon = Image.asset(
          'icons/realcard.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;
      case CardType.cabal:
        icon = Image.asset(
          'icons/cabal.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.credishop:
        icon = Image.asset(
          'icons/credishop.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      case CardType.banese:
        icon = Image.asset(
          'icons/banese.png',
          height: 48,
          width: 48,
          package: 'flutter_credit_card_brazilian',
        );
        isAmex = false;
        break;

      default:
        icon = Container(
          height: 48,
          width: 48,
        );
        isAmex = false;
        break;
    }
    return icon;
  }

  String getCardTypeName(String cardNumber) {
    String name = '';
    switch (detectCCType(cardNumber)) {
      case CardType.visa:
        name = 'VISA';
        break;
      case CardType.americanExpress:
        name = 'AMEX';
        break;
      case CardType.mastercard:
        name = 'MASTERCARD';
        break;
      case CardType.discover:
        name = 'DISCOVER';
        break;
      case CardType.assomise:
        name = 'ASSOMISE';
        break;
      case CardType.aura:
        name = 'AURA';
        break;
      case CardType.dinersclub:
        name = 'DINERS';
        break;
      case CardType.fortbrasil:
        name = 'FORTBRASIL';
        break;
      case CardType.elo:
        name = 'ELO';
        break;
      case CardType.hiper:
        name = 'HIPER';
        break;
      case CardType.hipercard:
        name = 'HIPERCARD';
        break;
      case CardType.jcb:
        name = 'JCB';
        break;
      case CardType.sorocred:
        name = 'SOROCRED';
        break;
      case CardType.realcard:
        name = 'REALCARD';
        break;
      case CardType.cabal:
        name = 'CABAL';
        break;
      case CardType.banese:
        name = 'BANESECARD';
        break;
      case CardType.credishop:
        name = 'CREDISHOP';
        break;
      default:
        name = '';
        break;
    }
    return name;
  }
}

class AnimationCard extends StatelessWidget {
  const AnimationCard({
    required this.child,
    required this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final Matrix4 transform = Matrix4.identity();
        transform.setEntry(3, 2, 0.001);
        transform.rotateY(animation.value);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}

class MaskedTextController extends TextEditingController {
  MaskedTextController(
      {String? text, required this.mask, Map<String, RegExp>? translator})
      : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      final String previous = _lastUpdatedText;
      if (beforeChange(previous, this.text)) {
        updateText(this.text);
        afterChange(previous, this.text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(this.text);
  }

  String mask;

  late Map<String, RegExp> translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String text) {
    if (text.isNotEmpty) {
      this.text = _applyMask(mask, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    updateText(text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    final String text = _lastUpdatedText;
    selection = TextSelection.fromPosition(TextPosition(offset: text.length));
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return <String, RegExp>{
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String? mask, String value) {
    String result = '';

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask!.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      final String maskChar = mask[maskCharIndex];
      final String valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar]!.hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}

enum CardType {
  otherBrand,
  mastercard,
  visa,
  americanExpress,
  discover,
  realcard,
  elo,
  assomise,
  dinersclub,
  fortbrasil,
  hiper,
  hipercard,
  jcb,
  sorocred,
  banese,
  credishop,
  cabal,
  aura
}
