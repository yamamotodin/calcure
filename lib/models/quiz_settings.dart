enum Operation { add, subtract, multiply, divide }
enum Digits { one, two, three }
enum TimeLimitOption { thirty, sixty, onetwenty, unlimited }

extension OperationExt on Operation {
  String get label {
    switch (this) {
      case Operation.add:
        return '＋';
      case Operation.subtract:
        return '－';
      case Operation.multiply:
        return '×';
      case Operation.divide:
        return '÷';
    }
  }
}

extension DigitsExt on Digits {
  String get label {
    switch (this) {
      case Digits.one:
        return '1桁';
      case Digits.two:
        return '2桁';
      case Digits.three:
        return '3桁';
    }
  }

  int get min {
    switch (this) {
      case Digits.one:
        return 1;
      case Digits.two:
        return 10;
      case Digits.three:
        return 100;
    }
  }

  int get max {
    switch (this) {
      case Digits.one:
        return 9;
      case Digits.two:
        return 99;
      case Digits.three:
        return 999;
    }
  }
}

extension TimeLimitExt on TimeLimitOption {
  String get label {
    switch (this) {
      case TimeLimitOption.thirty:
        return '30秒';
      case TimeLimitOption.sixty:
        return '1分';
      case TimeLimitOption.onetwenty:
        return '2分';
      case TimeLimitOption.unlimited:
        return 'なし';
    }
  }

  int? get seconds {
    switch (this) {
      case TimeLimitOption.thirty:
        return 30;
      case TimeLimitOption.sixty:
        return 60;
      case TimeLimitOption.onetwenty:
        return 120;
      case TimeLimitOption.unlimited:
        return null;
    }
  }
}

class QuizSettings {
  final Set<Operation> operations;
  final Digits digits;
  final TimeLimitOption timeLimit;

  const QuizSettings({
    required this.operations,
    required this.digits,
    required this.timeLimit,
  });
}
