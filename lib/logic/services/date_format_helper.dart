class DateFormatHelper {
  static String _getMonthName(String month) {
    switch (month) {
      case '1':
        return 'January';
      case '2':
        return 'February';
      case '3':
        return 'March';
      case '4':
        return 'April';
      case '5':
        return 'May';
      case '6':
        return 'June';
      case '7':
        return 'July';
      case '8':
        return 'August';
      case '9':
        return 'September';
      case '10':
        return 'October';
      case '11':
        return 'November';
      case '12':
        return 'December';
      default:
        return '';
    }
  }

  static String formatDate(String date) {
    final month = _getMonthName(date.split('/')[0]);
    final day = date.split('/')[1];
    final year = date.split('/')[2];
    return '$day $month $year';
  }
}
