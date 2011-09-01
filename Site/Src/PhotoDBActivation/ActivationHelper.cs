using System;
using System.Text;

namespace PhotoDBActivation
{
    public class ActivationHelper
    {
        private class DelphiArray16
        {
            private int[] array = new int[16];

            public int this[int index]
            {
                get
                {
                    return array[index - 1];
                }
                set
                {
                    array[index - 1] = value;
                }
            }
        }

        public static string GenerateCommercialActivationNumber(string applicationKey)
        {
            return GenerateActivationNumber(applicationKey, true);
        }

        public static string GenerateFreeActivationNumber(string applicationKey)
        {
            return GenerateActivationNumber(applicationKey, false);
        }

        public static string GenerateActivationNumber(string applicationKey, bool isFull)
        {
            string SSS;
            DelphiArray16 Ar = new DelphiArray16();

            string result = String.Empty;

            StringBuilder sb = new StringBuilder(applicationKey);
            for (int i = 1; i <= 8; i++)
            {
                SSS = ((int)Math.Abs(Math.Round(Math.Cos(Convert.ToByte(sb[i - 1]) + 100 * i + 0.34) * 16))).ToString("X8");
                sb[i - 1] = SSS[7];
            };
            applicationKey = sb.ToString();

            for (int i = 1; i <= 16; i++)
                Ar[i] = 0;

            for (int i = 1; i <= 8; i++)
                Ar[(i - 1) * 2 + 1] = Int32.Parse(new string(applicationKey[i - 1], 1), System.Globalization.NumberStyles.HexNumber);

            if (!isFull)
                Ar[2] = 15 - Ar[1];
            else
                Ar[2] = (Ar[1] + Ar[3] * Ar[7] * Ar[15]) % 15;

            if (!isFull && Ar[2] == (Ar[1] + Ar[3] * Ar[7] * Ar[15]) % 15)
                Ar[2] = (Ar[2] + 1) % 15;

            Ar[4] = Ar[2] * (Ar[3] + 1) * 123 % 15;
            Ar[6] = (int)Math.Round(Math.Sqrt(Ar[5]) * 100) % 15;
            Ar[8] = (Ar[4] + Ar[6]) * 17 % 15;

            Ar[10] = (int)((new Random()).NextDouble() * 15);
            Ar[12] = Ar[10] * Ar[10] * Ar[10] % 15;
            Ar[14] = Ar[7] * Ar[9] % 15;
            Ar[16] = 0;
            for (int i = 1; i <= 15; i++)
                Ar[16] = Ar[16] + Ar[i];

            Ar[16] = Ar[16] % 15;
            for (int i = 1; i <= 16; i++)
                result += Ar[i].ToString("X");

            return result;
        }
    }
}
