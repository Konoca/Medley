class ISO8601Duration {
  final String isoDurationString;

  ISO8601Duration(this.isoDurationString);

  Duration toDuration() {
    if (!RegExp(
            r"^(-|\+)?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$")
        .hasMatch(isoDurationString)) {
      return Duration.zero;
    }

    // final years = _parseUnit('Y');
    // final months = _parseUnit('M');
    // final weeks = _parseUnit('W');
    final days = _parseUnit('D');
    final hours = _parseUnit('H');
    final minutes = _parseUnit('M');
    final seconds = _parseUnit('S');

    return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  int _parseUnit(String unit) {
    final match = RegExp(r"\d+" + unit).firstMatch(isoDurationString);
    if (match == null) return 0;
    final string = match.group(0);
    return int.parse(string!.substring(0, string.length - 1));
  }
}
