{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses, TypeSynonymInstances #-}

module Language.Java.SWT.SWT where

import Language.Java.JVM.API
import Language.Java.JVM.Types

import Control.Monad
import Control.Monad.State
import Foreign.C

type SWTT = StateT (CallbackMapRef) JavaT

instance WithJava SWTT where
        getJavaCache = lift $ getJavaCache
        putJavaCache jc = lift $ putJavaCache jc
--                rt<-lift $ get
--                r<-liftIO $ f rt
--                return r

withSWT :: String -> SWTT a -> IO (a)
withSWT options f=do
        withJava options (do
                --listenerCls<-findClass "Language/Java/SWT/NativeListener" 
                --liftIO $ putStrLn ("listenerCls:"++(show listenerCls)) 
                cmr<-registerCallBackMethod "Language/Java/SWT/NativeListener" "nativeEvent" "org/eclipse/swt/widgets/Event"
                evalStateT f cmr
                )

addSWTCallBack :: JObjectPtr -> CLong -> Callback -> SWTT ()
addSWTCallBack widget eventid cb=do   
        cmr<-get
        index<-lift $ addCallBack cmr cb
        listener<-lift $ newObject "Language/Java/SWT/NativeListener" "(I)V" [JInt index]
        liftIO $ putStrLn ("listener:"++(show listener))
        lift $ voidMethod widget (Method "org/eclipse/swt/widgets/Widget" "addListener" "(ILorg/eclipse/swt/widgets/Listener;)V") [JInt eventid,JObj listener]
        

displayLoop :: JObjectPtr -> JObjectPtr -> SWTT()
displayLoop display shell= 
       do
               shellIsDisposed<-lift $ booleanMethod shell (Method "org/eclipse/swt/widgets/Widget" "isDisposed" "()Z") []
               when (not shellIsDisposed) (do 
                        displayDispatch<-lift $ booleanMethod display (Method "org/eclipse/swt/widgets/Display" "readAndDispatch" "()Z") []
                        when (not displayDispatch) (
                                lift $ voidMethod display (Method "org/eclipse/swt/widgets/Display" "sleep" "()Z") []
                                )
                        displayLoop display shell
                   )


push :: CLong
push = 8

selection :: CLong
selection = 13