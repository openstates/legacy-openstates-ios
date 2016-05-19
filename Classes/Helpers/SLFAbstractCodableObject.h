//
//  SLFAbstractCodableObject.h
//  OpenStates iOS
//
//  Created by Gregory Combs on 11/4/14.
//

@import Foundation;

@interface SLFAbstractCodableObject : NSObject <NSCopying, NSSecureCoding>

/**
 *  This method initializes a new object instance using the provided dictionary to populate the objects property values.
 *
 *  @param dictionaryRepresentation A dictionary with keys matching the receiver's property names.  Values should
 *                                  be of the same type as the matching property to avoid issues.
 *
 *  @return A newly initialized object instance.
 */
- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/**
 *
 *  Returns an object initialized from data in a given unarchiver.
 *
 *  @param aDecoder An unarchiver object.
 *
 *  @return `self`, initialized using the data in the decoder.
 */
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder; // NS_DESIGNATED_INITIALIZER

/**
 *  This method returns an dictionary containing the names and classes of all the properties of the receiver class that
 *  will be automatically saved, loaded and copied when instances are archived using NSKeyedArchiver/Unarchiver.
 *  Subclasses may opt to override this class method to customize the codable/copyable properties.
 *
 *  @warning Subclassers should not be tempted to include any mutable properties in this response if the subclass
 *           can ever be stored in a collection.  If a codable+mutable property mutates, the object's hash will
 *           change.  That would be bad.  If you must proceed anyway, perhaps consider custom implementations for
 *           the `hash` and `isEqual:` methods that ignore inconsequential property mutations.
 *
 *  @return A dictionary of the codable/copyable property keys and classes on the receiver class.
 */
+ (nullable NSDictionary *)codableKeysAndClasses;

/**
 *  As a getter, this method returns a dictionary of the keys and values of all the codable/copyable properties 
 *  of the receiver.
 *
 *  As a setter, this method populates the receiver's properties based on the key/value pairs found in the dictionary.
 */
@property (nullable,nonatomic,assign) NSDictionary *dictionaryRepresentation;

/**
 *  Return the receiver's value for the provided property key.
 *
 *  @param key A key string for the desired property value.
 *
 *  @return A property value corresponding to the key.
 */
- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key;

/**
 *  Set the receiver's value for the provided property key
 *
 *  @param object The value to set.
 *  @param key    The key string for the property value to set.
 */
- (void)setObject:(nullable id)object forKeyedSubscript:(nonnull NSString *)key;

@end
