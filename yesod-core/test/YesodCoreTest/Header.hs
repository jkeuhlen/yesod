{-# LANGUAGE OverloadedStrings, TemplateHaskell, QuasiQuotes,
  TypeFamilies, MultiParamTypeClasses, ViewPatterns #-}

module YesodCoreTest.Header
  ( headerTest
  , Widget
  , resourcesApp
  ) where

import Data.ByteString.Lazy (ByteString)
import qualified Data.Map as Map
import Data.Text (Text)
import Network.HTTP.Types (decodePathSegments, status200)
import Network.Wai
import Network.Wai.Test
import Test.Hspec
import Yesod.Core
import Yesod.Core.Handler

data App =
  App

mkYesod
  "App"
  [parseRoutes|
/header1 Header1R GET
/header2 Header2R GET
/header3 Header3R GET
|]

instance Yesod App

getHeader1R :: Handler RepPlain
getHeader1R = do
  addHeader "hello" "world"
  return $ RepPlain $ toContent ("header test" :: Text)

getHeader2R :: Handler RepPlain
getHeader2R = do
  addHeader "hello" "world"
  replaceOrAddHeader "hello" "sibi"
  return $ RepPlain $ toContent ("header test" :: Text)

getHeader3R :: Handler RepPlain
getHeader3R = do
  addHeader "hello" "world"
  addHeader "michael" "snoyman"
  addHeader "yesod" "framework"
  replaceOrAddHeader "yesod" "book"
  return $ RepPlain $ toContent ("header test" :: Text)

runner :: Session () -> IO ()
runner f = toWaiApp App >>= runSession f

addHeaderTest :: IO ()
addHeaderTest =
  runner $ do
    res <- request defaultRequest {pathInfo = decodePathSegments "/header1"}
    assertHeader "hello" "world" res

multipleHeaderTest :: IO ()
multipleHeaderTest =
  runner $ do
    res <- request defaultRequest {pathInfo = decodePathSegments "/header2"}
    assertHeader "hello" "sibi" res

header3Test :: IO ()
header3Test = do
  runner $ do
    res <- request defaultRequest { pathInfo = decodePathSegments "/header3"}
    assertHeader "hello" "world" res
    assertHeader "michael" "snoyman" res
    assertHeader "yesod" "book" res
                 
headerTest :: Spec
headerTest =
  describe "Test.Header" $ do
    it "addHeader" addHeaderTest
    it "multiple header" multipleHeaderTest
    it "persist headers" header3Test
