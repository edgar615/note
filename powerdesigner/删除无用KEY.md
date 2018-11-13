删除无用的data items

	'*****************************************************************************
	'文件：Delete useless data items.vbs
	'版本：1.0
	'版权：floodzhu (floodzhu@hotmail.com)，2005.1.6
	'功能：遍历概念模型，把无用的Data Items删除。
	'*****************************************************************************
	dim index
	index = 0
	
	dim model 'current model
	set model = ActiveModel

	If (model Is Nothing) Then
	   MsgBox "当前没有活动的模型。"
	ElseIf Not model.IsKindOf(PdCDM.cls_Model) Then
	   MsgBox "当前模型不是概念模型。"
	Else
	   View model
	   MsgBox index & "个无用字段被删除。"
	End If
	
	'*****************************************************************************
	'函数：View
	'功能：递归遍历
	'*****************************************************************************
	sub View(folder)
	   dim item
	   for each item in folder.DataItems
	      if not item.IsShortCut then
	         Visit item
	      end if
	   next
	  
	   '对子目录进行递归
	   dim subFolder
	   for each subFolder in folder.Packages
	      View subFolder
	   next
	end sub
	
	'*****************************************************************************
	'函数：Visit
	'功能：处理节点
	'*****************************************************************************
	sub Visit(node)
	 if node.UsedBy="" then
	      node.delete
	      index = index + 1
	   end if
	end sub

将名称写入注释

	Option   Explicit 
	ValidationMode   =   True 
	InteractiveMode   =   im_Batch 
	
	Dim   mdl   '   the   current   model 
	
	'   get   the   current   active   model 
	Set   mdl   =   ActiveModel 
	If   (mdl   Is   Nothing)   Then 
	      MsgBox   "There   is   no   current   Model " 
	ElseIf   Not   mdl.IsKindOf(PdPDM.cls_Model)   Then 
	      MsgBox   "The   current   model   is   not   an   Physical   Data   model. " 
	Else 
	      ProcessFolder   mdl 
	End   If 
	
	'   This   routine   copy   name   into   comment   for   each   table,   each   column   and   each   view 
	'   of   the   current   folder 
	Private   sub   ProcessFolder(folder)    
	      Dim   Tab   'running     table    
	      for   each   Tab   in   folder.tables    
	            if   not   tab.isShortcut then
	                     if  trim(tab.comment)="" then'如果有表的注释,则不改变它.如果没有表注释.则把name添加到注释里面.
	                        tab.comment   =   tab.name
	                     end if  
	                  Dim   col   '   running   column    
	                  for   each   col   in   tab.columns   
	                        if trim(col.comment)="" then '如果col的comment为空,则填入name,如果已有注释,则不添加;这样可以避免已有注释丢失.
	                           col.comment=   col.name   
	                        end if 
	                  next    
	            end   if    
	      next    
	  
	      Dim   view   'running   view    
	      for   each   view   in   folder.Views    
	            if   not   view.isShortcut and trim(view.comment)=""  then    
	                  view.comment   =   view.name    
	            end   if    
	      next    
	  
	      '   go   into   the   sub-packages    
	      Dim   f   '   running   folder    
	      For   Each   f   In   folder.Packages    
	            if   not   f.IsShortcut   then    
	                  ProcessFolder   f    
	            end   if    
	      Next    
	end   sub