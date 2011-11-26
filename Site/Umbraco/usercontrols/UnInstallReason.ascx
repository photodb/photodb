<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UnInstallReason.ascx.cs" Inherits="PhotoDBUserControls.UnInstallReason" %>

<asp:MultiView runat="server" ID="mvMain" ActiveViewIndex="0">
    <asp:View runat="server" ID="vForm">

        <div class="validation_summary">
            <asp:ValidationSummary runat="server" ID="vsUninstall" ShowMessageBox="false" ShowSummary="true"
                        DisplayMode="List" CssClass="red" ValidationGroup="vgUninstall" />
            <asp:RequiredFieldValidator runat="server" 
                        ID="rfvMessageText" ControlToValidate="txtMessageText" 
                        Display="None" SetFocusOnError="true" ValidationGroup="vgUninstall" />
        </div>

        <div class="form">
	        <div class="row required">
                <div class="row_label" ><%= GetProperty("nameText") %>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtName" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("emailText")%>:</div>
                <div class="requared_sign" >&nbsp;</div>
                <asp:TextBox runat="server" ID="txtEmail" CssClass="standartInput" MaxLength="100" />
            </div>
            <div class="row required">
                <div class="row_label"><%= GetProperty("messageText")%>:</div>
                <div class="requared_sign" >*</div>
                <asp:TextBox runat="server" ID="txtMessageText" CssClass="multilineInput" TextMode="MultiLine" Rows="7" Columns="30" />
            </div>
            <div class="row">
                <asp:Button runat="server" ID="btnSubmit" CssClass="standartBtn" 
                    onclick="btnSubmit_Click" ValidationGroup="vgUninstall" />
            </div>
        </div>

    </asp:View> 
    <asp:View runat="server" ID="vThankYouMessage">
        <asp:Literal runat="server" ID="ltrThankYouMessage" Mode="PassThrough" />
    </asp:View>
</asp:MultiView>
