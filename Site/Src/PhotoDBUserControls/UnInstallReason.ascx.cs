using System;
using System.Web.UI;
using PhotoDBDatabase.Classes;
using PhotoDBUserControls.Classes;
using PhotoDBUmbracoExtensions;

namespace PhotoDBUserControls
{
    public partial class UnInstallReason : UmbracoUserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                btnSubmit.Text = GetProperty("submitText");
                UpdateValidators();
            }
        }

        private void UpdateValidators()
        {
            string errorMessage = GetProperty("requiredText");
            rfvMessageText.ErrorMessage = String.Format(errorMessage, GetProperty("messageText"));
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            Page.Validate();
            if (Page.IsValid)
            {
                ContactUsManager.LeaveMessage(txtName.Text,
                    String.Empty,
                    txtEmail.Text,
                    String.Empty,
                    "UNINSTALL",
                    txtMessageText.Text,
                    "UNINSTALL");

                MailData data = new MailData();
                data.Add("Name", txtName.Text);
                data.Add("Reason", txtMessageText.Text);
                data.Add("Email", txtEmail.Text);
                Mailer.MailNotify("UnInstall :(", data);

                ltrThankYouMessage.Text = GetProperty("thankYouMessage");
                mvMain.ActiveViewIndex = 1;
            }
        }
    }
}