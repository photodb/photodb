using System;
using System.Text.RegularExpressions;
using PhotoDBActivation;
using PhotoDBDatabase.Classes;

namespace PhotoDBUserControls
{
    public partial class FreeActivation : System.Web.UI.UserControl
    {
        public static bool isEmail(string inputEmail)
        {
            inputEmail = inputEmail ?? String.Empty;
            string strRegex = @"^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}" +
                  @"\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\" +
                  @".)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$";
            Regex re = new Regex(strRegex);
            if (re.IsMatch(inputEmail))
                return (true);
            else
                return (false);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string programKey = Request["k"] ?? String.Empty;
            if (String.IsNullOrEmpty(programKey) || programKey.Length != 16)
            {
                ltrReply.Text = "k";
                return;
            }
            string programVersion = Request["v"] ?? String.Empty;
            if (String.IsNullOrEmpty(programKey))
            {
                ltrReply.Text = "v";
                return;
            }
            string firstName = Request["fn"] ?? String.Empty;
            if (String.IsNullOrEmpty(firstName))
            {
                ltrReply.Text = "fn";
                return;
            }
            string lastName = Request["ln"] ?? String.Empty;
            if (String.IsNullOrEmpty(lastName))
            {
                ltrReply.Text = "ln";
                return;
            }
            string email = Request["e"] ?? String.Empty;
            if (!isEmail(email))
            {
                ltrReply.Text = "e";
                return;
            }
            string phone = Request["p"] ?? String.Empty;
            string country = Request["co"] ?? String.Empty;
            string city = Request["ci"] ?? String.Empty;
            string address = Request["a"] ?? String.Empty;
            string freeActivationKey = ActivationHelper.GenerateFreeActivationNumber(programKey);
            ActivationManager.NewFreeActivation(firstName, lastName, email, phone,
                country, city, address, programKey, freeActivationKey, programVersion);

            ltrReply.Text = freeActivationKey;
        }
    }
}