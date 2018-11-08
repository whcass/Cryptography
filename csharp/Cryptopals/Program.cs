using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;


namespace Cryptopals
{

    class Program
    {
        public static void Main(string[] args)
        {
            string input = File.ReadAllText(@"7.txt");
            byte[] data = Util.Base64ToBytes(input);
            string result = Aes128EcbDecrypt(data,"YELLOW SUBMARINE");
            Console.WriteLine(result);

        }

        private static string Aes128EcbDecrypt(byte[] data, string key)
        {

            var aes = new AesManaged
            {
                Key = Util.ASCIIToBytes(key),
                Mode = CipherMode.ECB
            };

            string plaintext;

            var decryptor = aes.CreateDecryptor(aes.Key, aes.IV);
            using (var msDecrypt = new MemoryStream(data))
            {
                using (var csDecrypt = new CryptoStream(msDecrypt
                    , decryptor, CryptoStreamMode.Read))
                {
                    using (var srDecrypt = new StreamReader(
                        csDecrypt))
                    {
                        plaintext = srDecrypt.ReadToEnd();
                    }
                }
            }

            return plaintext.Trim('\u0004').Trim();


        }

        private static string Challenge6(string input)
        {
            string hexString = Hex.Base64ToHex(input);
            //hexString = testString;
            byte[] inputBytes = Encoding.Default.GetBytes(Util.StringToBinary(hexString));

            var probableKeySize = ProbableKeySize(hexString);

            inputBytes = Hex.HexStringToHex(hexString);
            List<byte[]> transposed = new List<byte[]>();
            for (int i = 0; i < probableKeySize; i++)
            {
                List<byte> transposedBlock = new List<byte>();
                for (int j = i; j <= inputBytes.Length - 1; j += probableKeySize)
                {
                    transposedBlock.Add(inputBytes[j]);
                }

                transposed.Add(transposedBlock.ToArray());
            }

            string key = "";
            foreach (byte[] bytes in transposed)
            {
                string byteString = BitConverter.ToString(bytes).Replace("-", "").ToLower();
                key += Xor.singeByteXorDecode(Util.GenerateCharArray().ToCharArray(), byteString);
            }

            string result = Hex.repeatingKeyXorDecode(hexString, key);
            //Console.WriteLine(result);
            return result;
        }

        private static int ProbableKeySize(string data)
        {
            //int[] keysize = Enumerable.Range(2, 41).ToArray();
            //int smallestEditDistance = 100;
            //int probableKeySize = 0;
            var optimalLength = 0;
            var optimalDistance = double.PositiveInfinity;
            var sampleSize = 12;
            for (int prospectiveKeyLength = 1; prospectiveKeyLength < 41; prospectiveKeyLength++)
            {
                var sum = 0.0;

                for (int sample = 0; sample < sampleSize; sample++)
                {
                    var a = data.Substring(2 * sample * prospectiveKeyLength * 2, prospectiveKeyLength * 2);
                    var b = data.Substring((2*sample + 1)*prospectiveKeyLength*2, prospectiveKeyLength*2);

                    sum += Util.GetHammingDistance(Hex.HexToBytes(a), Hex.HexToBytes(b));
                }

                sum /= prospectiveKeyLength * sampleSize;

                if (sum >= optimalDistance)
                {
                    continue;
                }

                optimalDistance = sum;
                optimalLength = prospectiveKeyLength;
            }

            return optimalLength;
        }


        private static void Test(string test, string result)
        {
            if (test == result)
            {
                Console.WriteLine("Yup, you did it");
                Console.WriteLine("Test String: "+test);
                Console.WriteLine("Result String: "+ result);
            }
            else
            {
                Console.WriteLine("Nope.");
                Console.WriteLine("You should have got: "+test);
                Console.WriteLine("You produced: "+ result);
            }
        }


    }
}