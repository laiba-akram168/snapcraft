import 'package:image/image.dart' as img; 

void main() { 
  var image = img.Image(width: 10, height: 10); 
  try { 
    img.adjustColor(image, brightness: 1.5); 
    print('Success'); 
  } catch(e) { 
    print('Error: $e'); 
  } 
}
