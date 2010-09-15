//
//  NSData+Encryption.m
//  TexLege
//
//  Created by Gregory Combs on 8/10/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "NSData+Encryption.h"
#import <CommonCrypto/CommonCryptor.h>


@implementation NSData (Encryption)

+ (NSData *) encryptedDataWithObject:(id)object {
	NSData *clearData = [NSKeyedArchiver archivedDataWithRootObject:object];
	NSData *encryptedData = [clearData AES256EncryptWithKey:[NSData cipher32Byte]];
	return encryptedData;
}

+ (id) decryptedObjectWithData:(NSData *)encryptedData {
	NSData *clearData = [encryptedData AES256DecryptWithKey:[NSData cipher32Byte]];
	id object = [NSKeyedUnarchiver unarchiveObjectWithData:clearData];
	return object;
}

// "Thisisalongstringsowatchoutkid"
// http://www.iwillapps.com/tuts/symcipher.php?sub_str=Thisisalongstringsowatchoutkid
+ (NSString*)cipher32Byte {
	char symCipher[] = { ';', 'R', ',', 'S', 'y', '&', 'W', '^', '#', 'x', '\\', '"', 'G', 'i', '7', 'q', '{', 'v', '8', 'o', '_', 'E', 'z', '3', '5', 'c', 'g', 'l', 'm', 'D', 'K', 'F', '(', ':', 'n', 'Z', '-', 'a', 'U', '*', 'X', 'I', 'j', 'Y', 'O', 'A', '=', 'f', '.', '`', '\'', ']', 'M', '%', 'u', '/', '|', 't', 'L', '4', '@', 'd', '+', 'k', 'p', 'e', '?', '0', ')', '1', 'P', '6', '[', 'h', 'r', 'H', 'B', 's', '9', 'C', '2', 'w', 'T', '}', 'V', '$', 'N', 'b', 'J', '!', '<', '>', 'Q' }; 
	char csignid[] = "]6[T[TpH9sPT}w[sPT9Np}?69V}r[0";
	NSInteger i = 0;
	for(i=0;i<strlen(csignid);i++)
	{
		int j = 0;
		for(j=0;j<sizeof(symCipher);j++)
		{
			if(csignid[i] == symCipher[j])
			{
				csignid[i] = j+0x21;
				break;
			}
		}
	}
	return [NSString stringWithCString:csignid encoding:NSUTF8StringEncoding];
}

- (NSData *)AES256EncryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

@end
