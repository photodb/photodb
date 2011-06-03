using System;
using System.Text.RegularExpressions;
using PhotoDBActivation;
using PhotoDBDatabase.Classes;
using PhotoDBUmbracoExtensions;

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
            return re.IsMatch(inputEmail);
        }

        public string base64DecodeUrl(string data)
        {
            try
            {
                data = data.Replace('*', '=');
                data = data.Replace('-', '+');
                data = data.Replace('_', '/');

                byte[] decbuff = Convert.FromBase64String(data);
                return System.Text.Encoding.Unicode.GetString(decbuff);
            }
            catch
            {
                return String.Empty;
            }
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
            string firstName = base64DecodeUrl(Request["fn"] ?? String.Empty);
            if (String.IsNullOrEmpty(firstName))
            {
                ltrReply.Text = "fn";
                return;
            }
            string lastName = base64DecodeUrl(Request["ln"] ?? String.Empty);
            if (String.IsNullOrEmpty(lastName))
            {
                ltrReply.Text = "ln";
                return;
            }
            string email = base64DecodeUrl(Request["e"] ?? String.Empty);
            if (!isEmail(email))
            {
                ltrReply.Text = "e";
                return;
            }
            string phone = base64DecodeUrl(Request["p"] ?? String.Empty);
            string country = base64DecodeUrl(Request["co"] ?? String.Empty);
            string city = base64DecodeUrl(Request["ci"] ?? String.Empty);
            string address = base64DecodeUrl(Request["a"] ?? String.Empty);
            string freeActivationKey = ActivationHelper.GenerateFreeActivationNumber(programKey);
            ActivationManager.NewFreeActivation(firstName, lastName, email, phone,
                country, city, address, programKey, freeActivationKey, programVersion);

            MailData data = new MailData();
            data.Add("First Name", firstName);
            data.Add("Last Name", lastName);
            data.Add("Email", email);
            data.Add("Phone", phone);
            data.Add("Country", country);
            data.Add("City", city);
            data.Add("Address", address);
            data.Add("Program Key", programKey);
            data.Add("Activation Key", freeActivationKey);
            data.Add("Program Version", programVersion);
            Mailer.MailNotify("Activation", data);

            ltrReply.Text = freeActivationKey;
        }
    }
}