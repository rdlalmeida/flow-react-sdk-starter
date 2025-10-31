/**
    Simple function that calls the "decodeHex" function from the String provided (the assumption is that it is hex encoded as a public encryption key would be)
**/

access(all) view fun main(hexCodedString: String): [UInt8] {
    return hexCodedString.decodeHex()
}