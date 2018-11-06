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
            string input = File.ReadAllText(@"6.txt");

            int[] keysize = Enumerable.Range(2, 41).ToArray();
            for (int i = 2; i < 40; i++)
            {

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