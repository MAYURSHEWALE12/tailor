class GarmentType {
  static const String shirt = 'shirt';
  static const String pant = 'pant';
  static const String kurta = 'kurta';
  static const String blouse = 'blouse';
  static const String sadra = 'sadra';

  static const List<String> all = [shirt, pant, kurta, blouse, sadra];

  static String label(String type) {
    switch (type) {
      case shirt:
        return 'Shirt';
      case pant:
        return 'Pant';
      case kurta:
        return 'Kurta';
      case blouse:
        return 'Blouse';
      case sadra:
        return 'Sadra';
      default:
        return type;
    }
  }
}

class OrderStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in-progress';
  static const String completed = 'completed';
  static const String delivered = 'delivered';

  static const List<String> all = [pending, inProgress, completed, delivered];

  static String label(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case inProgress:
        return 'In Progress';
      case completed:
        return 'Completed';
      case delivered:
        return 'Delivered';
      default:
        return status;
    }
  }
}

class MeasurementFields {
  static const Map<String, List<String>> byGarment = {
    GarmentType.shirt: [
      'length', 'chest', 'waist', 'stomach', 'shoulder',
      'sleeve', 'collar', 'neck', 'armhole', 'biceps',
    ],
    GarmentType.pant: [
      'pantLength', 'waist', 'seat', 'thigh', 'knee',
      'bottom', 'rise', 'hip',
    ],
    GarmentType.kurta: [
      'kurtalength', 'chest', 'waist', 'stomach', 'shoulder',
      'sleeve', 'collar', 'kurtaghera', 'armhole', 'biceps',
    ],
    GarmentType.blouse: [
      'blouseLength', 'bust', 'blouseWaist', 'hip', 'shoulder',
      'backNeck', 'frontNeck', 'blouseSleeve', 'armhole',
    ],
    GarmentType.sadra: [
      'length', 'chest', 'waist', 'stomach', 'shoulder',
      'sleeve', 'collar', 'armhole', 'biceps',
    ],
  };

  static const Map<String, String> labels = {
    'length': 'Length (लांबी)',
    'chest': 'Chest (छाती)',
    'waist': 'Waist (कंबर)',
    'stomach': 'Stomach (पोट)',
    'shoulder': 'Shoulder (खांदा)',
    'sleeve': 'Sleeve (बाही)',
    'collar': 'Collar (गळा)',
    'neck': 'Neck',
    'armhole': 'Armhole',
    'biceps': 'Biceps',
    'pantLength': 'Length',
    'seat': 'Seat',
    'thigh': 'Thigh',
    'knee': 'Knee',
    'bottom': 'Bottom',
    'rise': 'Rise',
    'hip': 'Hip',
    'kurtalength': 'Length (लांबी)',
    'kurtaghera': 'Ghera (घेरा)',
    'blouseLength': 'Length (लांबी)',
    'bust': 'Bust (बस्ट)',
    'blouseWaist': 'Waist (कंबर)',
    'backNeck': 'Back Neck',
    'frontNeck': 'Front Neck',
    'blouseSleeve': 'Sleeve (बाही)',
  };
}

class StyleOptions {
  static const List<String> styles = ['Formal', 'Casual', 'Traditional'];

  static const Map<String, String> colors = {
    'Navy Blue': '#1A3A5C',
    'White': '#FFFFFF',
    'Black': '#000000',
    'Gray': '#808080',
    'Beige': '#F5F5DC',
    'Maroon': '#800000',
    'Forest Green': '#228B22',
    'Burgundy': '#800020',
  };
}
