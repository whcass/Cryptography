using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace Cryptopals
{
    class Program
    {
        public static void Main(string[] args)
        {

            string input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736";
            //string test = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272";
            //string against = "686974207468652062756c6c277320657965";
            char[] charArray = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".ToCharArray();
            foreach (char c in charArray)
            {
                char[] result = singleByteXor(input, c);
                int matches = characterAnalysis(result);
                if (matches > 20)
                {
                    Console.WriteLine("Possible match found using - "+c);
                    Console.WriteLine(new string(result));
                    Console.WriteLine("Maches: "+matches+"\n");
                }
            }

            //Test(test,result);
        }

        private static char[] singleByteXor(string input, char c)
        {
            byte[] hexInput = HexStringToHex(input);
            char[] result = new char[hexInput.Length];

            for (int i = 0; i < hexInput.Length; i++)
            {
                result[i] = Convert.ToChar(hexInput[i] ^ c);
            }

            return result;

        }

        private static int characterAnalysis(char[] inArray)
        {
            Regex rx = new Regex(@"[ETAOIN SHRDLU]",RegexOptions.IgnoreCase);
            int matches = 0;
            foreach (char c in inArray)
            {
                if (rx.IsMatch(c.ToString()))
                {
                    matches++;
                }
            }
            return matches;
        }

        private static string HexToBase64(string input)
        {
            return Convert.ToBase64String(HexStringToHex(input));
        }

        private static string FixedXOR(string input, string against)
        {
            byte[] hexInput = HexStringToHex(input);
            byte[] hexAgainst = HexStringToHex(against);

            byte[] result = new byte[hexInput.Length];
            for (int i = 0; i < hexInput.Length; i++)
            {
                result[i] = (byte) (hexInput[i] ^ hexAgainst[i]);
            }

            string hex = ConvertHexToString(result);

            return hex;
        }

        private static byte[] HexStringToHex(string inputHex)
        {
            var resultArray = new byte[inputHex.Length / 2];
            for (int i = 0; i < resultArray.Length; i++)
            {
                resultArray[i] = Convert.ToByte(inputHex.Substring(i * 2, 2), 16);
            }
            return resultArray;
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

        private static string ConvertHexToString(byte[] input)
        {
            return BitConverter.ToString(input).Replace("-", "").ToLower();
        }
    }
}