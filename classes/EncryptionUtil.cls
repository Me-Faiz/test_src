/**
 * Created by P01242 on 1/9/2019.
 */

public with sharing class EncryptionUtil {

    private Blob key;
    private Blob vector;
    private String algorithm;
    public EncryptionUtil(String algorithm,String key,String vector)
    {
        this.algorithm=algorithm;
        this.key=Blob.valueOf(key);
        this.vector = Blob.valueOf(vector);

    }
    public String encrypt(String encodingString)
    {
        Blob blobData = Crypto.encrypt(algorithm, key, vector,Blob.valueOf(encodingString));
        return EncodingUtil.base64Encode(blobData);
    }
    public String decrypt(String str)
    {
        Blob blobData = EncodingUtil.base64Decode(str);
        Blob decryptedBlob = Crypto.decrypt(algorithm, key,vector, blobData);
        return decryptedBlob.toString();
    }
}