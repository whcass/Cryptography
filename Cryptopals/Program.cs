using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;


namespace Cryptopals
{

    class Program
    {




        public static void Main(string[] args)
        {
            string testString = Xor.repeatingKeyXorEncode("Burning 'em, if you ain't quick and nimble", "ICE");
            string input = File.ReadAllText(@"6.txt");
            string hexString = Hex.Base64ToHex(input);
            hexString = testString;
            byte[] inputBytes = Encoding.Default.GetBytes(Util.StringToBinary(hexString));
            int[] keysize = Enumerable.Range(2, 41).ToArray();
            int smallestEditDistance = 100;
            int probableKeySize = 0;
            for (int i = 0; i < keysize.Length; i++)
            {
                byte[] a = Util.SubArray(inputBytes,0, keysize[i]);
                byte[] b = Util.SubArray(inputBytes,keysize[i], keysize[i]);

                int editDistance = Util.GetHammingDistance(a,b)/keysize[i];
                //Console.WriteLine("{0}\n{1}\n{2}\n",a,b,editDistance);
                if (editDistance < smallestEditDistance)
                {
                    smallestEditDistance = editDistance;
                    probableKeySize = keysize[i];
                }
            }

//            int len = inputBytes.Length / probableKeySize;
//            byte[,] brokenDown = new byte[2,len];
//            for (int i = 0; i < brokenDown.Length; i++)
//            {
//                brokenDown[i,0] = new byte[]{Util.SubArray(inputBytes, i, probableKeySize)};
//            }

            //Console.WriteLine(probableKeySize);
            if (probableKeySize != 3)
            {
                Console.WriteLine("Nope");
            }
            else
            {
                Console.WriteLine("wahey");
            }

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