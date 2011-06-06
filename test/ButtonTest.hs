
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
           --listenerCls<-lift $ findClass "Language/Java/SWT/NativeListener" 
          --liftIO $ putStrLn ("listenerCls:"++(show listenerCls)) 
          
          display<-newObject "org/eclipse/swt/widgets/Display" "()V" []
          
          shell<-newObject "org/eclipse/swt/widgets/Shell" "(Lorg/eclipse/swt/widgets/Display;)V" [JObj display]
          
          text<-toJString "Hello SWT From Haskell"
          voidMethod shell (Method "org/eclipse/swt/widgets/Shell" "setText" "(Ljava/lang/String;)V") [JObj text]
          voidMethod shell (Method "org/eclipse/swt/widgets/Shell" "setSize" "(II)V") [JInt 300,JInt 200]

          layout<-newObject "org/eclipse/swt/layout/FillLayout" "()V" []
          
          voidMethod shell (Method "org/eclipse/swt/widgets/Shell" "setLayout" "(Lorg/eclipse/swt/widgets/Layout;)V") [JObj layout]
         
          button<-newObject "org/eclipse/swt/widgets/Button" "(Lorg/eclipse/swt/widgets/Composite;I)V" [JObj shell,JInt 8]  -- SWT.PUSH
          
          text2<-toJString "Click me"
          voidMethod button (Method "org/eclipse/swt/widgets/Button" "setText" "(Ljava/lang/String;)V") [JObj text2]
          
          let cb=(\_->do
                        liftIO $ putStrLn ("button clicked")
                        nc<-liftIO $ modifyMVar count (\c->do
                                let nc=c+1
                                return(nc,nc)
                             )
                        let s=if nc==1 then "once." else ((show nc)++ " times.")
                        text3<-toJString ("Clicked "++s)
                        voidMethod button (Method "org/eclipse/swt/widgets/Button" "setText" "(Ljava/lang/String;)V") [JObj text3]
                        )        
          
          --listener<-newObject listenerCls "(I)V" [JInt index]
          --liftIO $ putStrLn ("listener:"++(show listener))
          --voidMethod button "addListener" "(ILorg/eclipse/swt/widgets/Listener;)V" [JInt 13,JObj listener]  -- SWT.Selection
                        
          addSWTCallBack button 13 cb
          
          voidMethod shell (Method "org/eclipse/swt/widgets/Shell" "open" "()V") []
          displayLoop display shell
          
          voidMethod display (Method "org/eclipse/swt/widgets/Display" "dispose" "()V") []
          )
 