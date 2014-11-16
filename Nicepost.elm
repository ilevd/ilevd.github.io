module Nicepost where

import Html (..)
import Html.Attributes as HA
import Html.Events (..)
import Html.Optimize.RefEq as Ref
import Html.Optimize.StructEq (..)
import Html.Tags (..)
import JavaScript.Experimental as JS
import Json
import Dict
import List
import Maybe
import Text
import String
import Graphics.Element as GE
import Graphics.Input as GI



-- Data types ----------------

type Group  = {id:Int, name:String, screen_name:String, is_closed:Int, -- type':String,
    photo_50:String, photo_100:String, photo_200:String}
type Post   = {id:Int, text:String, likes:Int, date:Float, photos:[Photo], audios:[Audio]} 
type Photo  = {photo_75:String, photo_130:String, photo_604:String, width:Int, height:Int}
type Audio  = {title:String, artist:String}

-- data PostWindow = {showWindow:Bool, post:Post, img:String} | None
data PostWindow = Window Post String | None


type State  = 
    { currentToggle : String
    , currentGroup  : Int
    , groups        : [Group]
    , posts         : [Post]
    , openPosts     : [Int]
    , postWindow    : PostWindow
    }


data Action
    = Noop
    | GetPosts [Post]
    | ChangeToggle 
    | ChangeGroup Int
    | ClickText Int
    | OpenImage PostWindow
    | NewGroups [Group]



-- main update state function --

update : Action -> State -> State
update action state = 
    case action of
        Noop -> state

        NewGroups groups -> 
            case groups of
                h :: t -> {state | groups <- groups, currentGroup <- h.id, openPosts <- []} --, posts <- []}
                nogroup -> {state | groups <- nogroup, openPosts <- [], posts <- []}

        ChangeGroup groupID ->
            {state | posts <- [], openPosts <- [], currentGroup <- groupID}

        GetPosts posts ->
            case state.posts of
                [] -> { state | posts <- posts}
                oldPosts -> { state | posts <- oldPosts ++ posts}

        ClickText postID ->
            case List.filter (\id -> id == postID) state.openPosts of
                [] -> { state | openPosts <- postID :: state.openPosts }
                _ -> { state | openPosts <- List.filter (\id -> id /= postID) state.openPosts }

        ChangeToggle ->
            {state | openPosts <- [], posts <- []}

        OpenImage postWindow -> 
            { state | postWindow <- postWindow}



{------------- Utils funcitons ------------}

dividePosts : [Post] -> ([Post], [Post], [Post])
dividePosts posts = divp [] [] [] posts 0

divp : [a] -> [a] -> [a] -> [a] -> Int -> ([a], [a], [a])
divp posts1 posts2 posts3 posts acc = 
    case posts of
        [] -> (posts1, posts2, posts3)
        h :: t -> 
            let (p1, p2, p3) = divp posts1 posts2 posts3 t (acc+1) in
            case acc % 3 of
                0 -> ((h :: p1), p2, p3)
                1 -> (p1, (h :: p2), p3) 
                2 -> (p1, p2, (h :: p3))                

getNextImg : Post -> String -> String
getNextImg post imgSrc =
    getNext post.photos post.photos .photo_604 imgSrc
            
getNext : [a] -> [a] -> (a -> b) -> b -> b
getNext all arr f elem = 
  case arr of
    h :: t -> 
      if  | f h == elem -> f <| head (t ++ all)
          | otherwise -> getNext all t f elem           

{------------- View ----------------------}

display : State -> Element
display {currentToggle, currentGroup, groups, posts, openPosts, postWindow} =
    let divWin = case postWindow of
        Window post img -> [getPostWindow post img , getBlackBackground]
        None -> []
    in 
        div [] ([
            Ref.lazy displayToggles toggleList,
            Ref.lazy2 groupsDiv groups currentGroup,
            Ref.lazy2 postColumns posts openPosts
        ] ++ divWin)
        |> toElement 1000 700

getBlackBackground : Html
getBlackBackground =
    div [HA.class "win_black"] []

getPostWindow : Post -> String -> Html
getPostWindow post imgSrc = 
    let pointerProp = 
        if  | List.length post.photos > 1 -> 
                [ style [prop "cursor" "pointer", prop "min-width" "200px"]
                , HA.alt "Loading"
                , onclick actions.handle (always (OpenImage (Window post (getNextImg post imgSrc)))) ]
            | otherwise -> []
    in 
    div [ HA.class "win_container"]
        [ div [HA.class "win"]
            [
                p [HA.class "post_window_p"]
                    [
                    a [HA.class "song", 
                        onclick actions.handle (always (OpenImage None)) ]
                        [
                        text "Закрыть"
                        ]
                    ]
                , img ([HA.src imgSrc]++pointerProp) []
            ]
        ]


{----------------- elm-html ---------------}

postColumns : [Post] -> [Int] -> Html
postColumns posts openPosts =
    case posts of 
        [] -> displayLoader
        _ ->
            let (posts1, posts2, posts3) = dividePosts posts 
            in 
                div [] 
                    [ postColumn "post-column1" posts1 openPosts
                    , postColumn "post-column2" posts2 openPosts
                    , postColumn "post-column3" posts3 openPosts
                    ]


postColumn : String -> [Post] -> [Int] -> Html
postColumn name posts openPosts = 
    div [HA.class "columnpost", HA.id name]
        (map (postHtml openPosts) posts)


postHtml : [Int] -> Post -> Html
postHtml openPosts post = 
    let imgs = 
        case post.photos of
            ph :: t ->  getImgs post
            _       ->  []
    in 
        div [HA.class "main"]
            ( imgs ++ [ getTextBlock post openPosts ] ++ (getAudios post) ++ [postFooter post] )


getTextBlock : Post -> [Int] -> Html
getTextBlock post openPosts =
    let (txt, className) =
        if  | String.length post.text > 240 ->
            case List.filter (\id -> id == post.id) openPosts of
                [] -> ( (String.left 140 post.text) ++ "... (развернуть)", "textBlockClicked")
                _ -> (post.text, "textBlockClicked")
            | otherwise -> (post.text, "textBlock")
    in 
    div [HA.class className
        , onclick actions.handle (always (ClickText post.id)) ]
        [
            text txt
        ] 


getImgs : Post -> [Html]
getImgs post =
    let photos = post.photos
        getImg_290 = getImg 290 .photo_604 post
        getImg_144 = getImg 144 .photo_604 post
        getImg_95  = getImg 95  .photo_130 post
    in 
        case List.length photos of
        1 -> map getImg_290 photos 
        2 -> map getImg_144 photos
        3 -> map getImg_95 (List.take 3 photos)
        4 -> map getImg_144 (List.take 2 photos) 
             ++ map getImg_144 (last2_3 photos)
        5 -> map getImg_144 (List.take 2 photos)  
             ++ map getImg_95 (last2_3 photos) 
        _ -> map getImg_95 (List.take 6 photos)


last2_3 : [a] -> [a]
last2_3 (_ :: _ :: t) = t

getImg : Int -> (Photo -> String) -> Post -> Photo -> Html
getImg w getSrc post photo = 
    img [ HA.class "mainimg"
        , HA.src (getSrc photo)
        , HA.width (show w)
        , onclick actions.handle (always (OpenImage (Window post photo.photo_604)) )
        ]
        []


getAudios : Post -> [Html]
getAudios post = map getAudio post.audios

getAudio : Audio -> Html
getAudio audio =
    a [HA.class "song"] 
    [
        text (String.left 40 (audio.artist ++ " - " ++ audio.title))
    ]


postFooter : Post -> Html
postFooter post = 
    div [HA.class "footer"] [
        img [HA.class "likesimg",
            HA.src "/resources/like_vk2.png"] [],
        span [HA.class "likestext"] 
            [text (show post.likes)],
        a [HA.class "postbutton"]
            [text "На стену!"],
        a [HA.class "postbutton"]
            [text "Другу!"],
        a [HA.class "postbutton"]
            [text "В группу!"]
    ]


displayLoader : Html
displayLoader =
    img [HA.src "/resources/loader.gif", style [prop "marginLeft" "455px", prop "marginTop" "200px"]][]


{---------------- groups -----------}

groupsDiv : [Group] -> Int -> Html
groupsDiv groups currentGroup = 
    div [HA.class "groups"]
        (map (groupImg currentGroup) groups)


groupImg : Int -> Group -> Html
groupImg currentGroup group = 
    let cls =
        if  | group.id == currentGroup -> "group_checked"
            | otherwise ->  "groupimg"
    in
    img [
        HA.class cls,
        HA.src group.photo_50,
        HA.title (group.name ++ " | " ++ group.screen_name),
        onclick groupClick.handle (\_ -> group.id)
    ] []




{------------ toggle buttons ------}

toggleList: [String]
toggleList = ["Юмор","Любовь", "Новости", "Картинки", "Умное", "Цитаты",
        "Музыка", "Игры", "Спорт", "Авто", "Бизнес",
        "Мода", "Рецепты", "English", "Открытки", "Мои" ]

displayToggles : [String] -> Html
displayToggles toggles = 
    div [HA.class "toggle-btn-grp cssonly main-toggle"]
        (map getToggle toggles)

getToggle : String -> Html
getToggle name = 
    div [ onclick toggleClick.handle (\_ -> name) ]
    [
        input [HA.type' "radio", HA.name "group1"] [],
        label [HA.class "toggle-btn"][
            text name
        ]
    ]





{-- Inputs---------}

main : Signal Element
--main = display <~ getGroups ~ currentPosts 
main = display <~ currentState

currentState : Signal State
currentState = foldp update defaultState mainSignal

defaultState : State
defaultState = 
    { currentToggle = "Юмор"
    , currentGroup  = 0
    , groups        = []
    , posts         = []
    , openPosts     = []
    , postWindow    = None -- PostWindow {showWindow = False, None, "hello"}
    }

mainSignal : Signal Action
mainSignal = merges 
    [ actions.signal
    , newGroups
    , getNewPosts
    , groupClickAction
    , toggleClickAction
    ]


actions : GI.Input Action
actions = GI.input Noop

-- Incoming messages --
port getGroups : Signal [Group]
port getWallPosts : Signal (Int, [Post])

newGroups : Signal Action
newGroups = NewGroups <~ getGroups

getNewPosts : Signal Action
getNewPosts = 
    let convert (offset, posts) = GetPosts posts
    in convert <~ getWallPosts



-- Actions --

groupClick : GI.Input Int
groupClick = GI.input 1

toggleClick : GI.Input String
toggleClick = GI.input "Юмор"

textBlockclick : GI.Input Int
textBlockclick = GI.input 0


{-- Outcoming messages --------}

port htmlGroupClick : Signal Int
port htmlGroupClick = groupClick.signal

port htmlToggleClick : Signal String
port htmlToggleClick = toggleClick.signal

groupClickAction : Signal Action
groupClickAction = ChangeGroup <~ htmlGroupClick

toggleClickAction : Signal Action
toggleClickAction = (\_ -> ChangeToggle) <~ htmlToggleClick
