import 'dart:io';
import 'package:aws_s3_client/aws_s3_client.dart';
import 'package:uuid/uuid.dart';
import 'aws-data.dart' as AWS;
import 'package:path/path.dart' as path;

class AwsS3 {
  //String host = 'https://customer-profile-bucket.s3.sa-east-1.amazonaws.com';
  Uuid uuid = Uuid();
  Spaces spaces = Spaces(
    region: AWS.region,
    accessKey: AWS.accessKey,
    secretKey: AWS.secretKey,
  );
  Future<String> uploadFile(File file) async {
    String fileId = uuid.v4();
    String fileExtension = path.extension(file.path);
    Bucket bucket = spaces.bucket('bucket-saycheese');
    String etag = await bucket.uploadFile('profiles/$fileId$fileExtension',
        file.readAsBytesSync(), 'multipart/form-data', Permissions.public);
    print('upload etag: $etag');
    return '$fileId$fileExtension';
  }
}
