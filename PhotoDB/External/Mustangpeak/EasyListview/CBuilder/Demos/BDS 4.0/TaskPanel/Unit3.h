//$$---- Form HDR ----
//---------------------------------------------------------------------------

#ifndef Unit3H
#define Unit3H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
//---------------------------------------------------------------------------
class TEasyTaskPanelForm3 : public TEasyTaskPanelForm
{
__published:	// IDE-managed Components
	TRadioButton *RadioButton1;
	TRadioButton *RadioButton2;
	TComboBox *ComboBox1;
private:	// User declarations
public:		// User declarations
	__fastcall TEasyTaskPanelForm3(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TEasyTaskPanelForm3 *EasyTaskPanelForm3;
//---------------------------------------------------------------------------
#endif
