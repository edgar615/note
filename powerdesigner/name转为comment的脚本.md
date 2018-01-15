```
' 如果comment为空,则填入name;如果comment不为空,则保留不变.这样可以避免已有的注释丢失.

Option Explicit
ValidationMode = True
InteractiveMode = im_Batch

Dim mdl ' the current model

' get the current active model
Set mdl = ActiveModel
If (mdl Is Nothing) Then
    MsgBox "There is no current Model "
ElseIf Not mdl.IsKindOf(PdPDM.cls_Model) Then
    MsgBox "The current model is not an Physical Data model. "
Else
    ProcessFolder mdl
End If

' This routine copy name into comment for each table, each column and each view of the current folder
Private sub ProcessFolder(folder)
Dim Tab 'running table
for each Tab in folder.tables
    if not tab.isShortcut then
        if trim(tab.comment)="" then '如果有表的注释,则不改变它;如果没有表注释,则把name添加到注释中.
            tab.comment = tab.name
        end if
        Dim col ' running column
        for each col in tab.columns
            if trim(col.comment)="" then '如果col的comment为空,则填入name;如果已有注释,则不添加.这样可以避免已有注释丢失.
                col.comment= col.name
            end if
        next
    end if
next

Dim view 'running view
for each view in folder.Views
    if not view.isShortcut and trim(view.comment)="" then
        view.comment = view.name
    end if
next

' go into the sub-packages
Dim f ' running folder
For Each f In folder.Packages
    if not f.IsShortcut then
        ProcessFolder f
    end if
Next
end sub
```