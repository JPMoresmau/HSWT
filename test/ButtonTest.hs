
module Main where

import Paths_HSWT

import Control.Monad.State

import Language.Java.JVM.API
import Language.Java.JVM.Types
import Language.Java.SWT.SWT

import Control.Concurrent.MVar

import System.FilePath

main :: IO()
main = do
      count<-newMVar 0
      --eventW<-wrap (event ior)
      --ret<-withCString "-Djava.class.path=bin;d:/dev/java/eclipse/plugins/org.eclipse.swt.win32.win32.x86_3.5.2.v3557f.jar" (\s->start s eventW)
      bin <- getDataDir
      let cp=bin ++ "/src" ++ [searchPathSeparator] ++ "d:/dev/java/eclipse/plugins/org.eclipse.swt.win32.win32.x86_3.5.2.v3557f.jar"
      putStrLn cp
      withSWT ("-Djava.class.path="++cp) (do
      --putStrLn (show ret)
      --when (ret>(-1)) (do
          displayCls<- findClass "org/eclipse/swt/widgets/Display"
          shellCls<- findClass "org/eclipse/swt/widgets/Shell"
          layoutCls<- findClass "org/eclipse/swt/layout/FillLayout"
          buttonCls<- findClass "org/eclipse/swt/widgets/Button"
          --listenerCls<-lift $ findClass "Language/Java/SWT/NativeListener" 
          --liftIO $ putStrLn ("listenerCls:"++(show listenerCls)) 
          
          display<-newObject displayCls "()V" []
          
          shell<-newObject shellCls "(Lorg/eclipse/swt/widgets/Display;)V" [JObj display]
          
          text<-toJString "Hello SWT From Haskell"
          voidMethod shell (buttonCls,"setText","(Ljava/lang/String;)V") [JObj text]
          voidMethod shell (buttonCls,"setSize","(II)V") [JInt 300,JInt 200]

          layout<-newObject layoutCls "()V" []
          
          voidMethod shell (shellCls,"setLayout","(Lorg/eclipse/swt/widgets/Layout;)V") [JObj layout]
         
          button<-newObject buttonCls "(Lorg/eclipse/swt/widgets/Composite;I)V" [JObj shell,JInt 8]  -- SWT.PUSH
          
          text2<-toJString "Click me"
          voidMethod button (buttonCls,"setText","(Ljava/lang/String;)V") [JObj text2]
          
          let cb=(\_->do
                        liftIO $ putStrLn ("button clicked")
                       
                        modifyMVar count (\c->do
                                let nc=c+1
                                let s=if nc==1 then "once." else ((show nc)++ " times.")
                                text3<-toJString ("Clicked "++s)
                                voidMethod button (buttonCls,"setText","(Ljava/lang/String;)V") [JObj text3]
                                return(nc,())
                             )
                                
                        )
          
          --listener<-newObject listenerCls "(I)V" [JInt index]
          --liftIO $ putStrLn ("listener:"++(show listener))
          --voidMethod button "addListener" "(ILorg/eclipse/swt/widgets/Listener;)V" [JInt 13,JObj listener]  -- SWT.Selection
                        
          addSWTCallBack button 13 cb
          
          voidMethod shell (shellCls,"open","()V") []
          displayLoop display shell
          
          voidMethod display (displayCls,"dispose","()V") []
          )
 