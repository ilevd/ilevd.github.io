{--
    let photos = post.photos
        getImg_290 = getImg 290 .photo_604 post
        getImg_144 = getImg 144 .photo_604 post
        getImg_95  = getImg 95  .photo_130 post
    in 
        case List.length photos of
        1 -> map (getImg 290 .photo_604 post) photos 
        2 -> map (getImg 144 .photo_604 post) photos
        3 -> map (getImg 95 .photo_130 post) (List.take 3 photos)
        4 -> map (getImg 144 .photo_130 post) (List.take 2 photos) 
             ++ map (getImg 144 .photo_130 post) (last2_3 photos)
        5 -> map (getImg 144 .photo_130 post) (List.take 2 photos)  
             ++ map (getImg 95 .photo_130 post) (last2_3 photos) 
        _ -> map (getImg 95 .photo_130 post) (List.take 6 photos)
--}


currentPosts : Signal [Post]
currentPosts = foldp updatePosts [] getWallPosts

updatePosts : (Int, [Post]) -> [Post] -> [Post]
updatePosts (offset, newposts) posts = 
    case offset of 
        0 -> newposts
        _ -> posts ++ newposts





{--
postHtml : Post -> Html
postHtml post = 
    let imgs = 
        case post.photos of
            ph :: t ->  [getImg ph]
            _       ->  []
    in 
        div [style (postStyle ++ quoteStyle)]
            (imgs ++ [
                div [] [text (String.left 140 post.text)], 
                postFooter post
            ])


postFooter : Post -> Html
postFooter post = 
    div [style leftStyle] 
        [
        img [ HA.src "/resources/like_vk2.png"] [],
        text (show post.likes)
        ]


getImg : Photo -> Html
getImg photo = 
    img [
        HA.src photo.photo_604, 
        HA.width "250", 
        HA.height (show(getPhotoHeight 250 photo))]
    []

--}




{-- CSS Styles -------------------}
{--
postStyle : [CssProperty]
postStyle = [
    prop "width" "250px",
    prop "backgroundColor" "#FEFEFE",
    prop "border" "1px solid #DDDDDD",
    prop "padding" "10px",
    prop "margin" "10px"
    ]

quoteStyle : [CssProperty]
quoteStyle = [ 
    prop "fontFamily" "tahoma",
    prop "fontSize" "11px"
    ]
--}
{--
leftStyle : [CssProperty]
leftStyle = [
     prop "width" "250"
    -- ,prop "height" "20px"
    --,prop "cssFloat" "left"
    ]

--}

{--- json parsing better do this in javascript :) --}
{--
 --main = (parseJson >> asText) <~ getWallPosts
parseJson json = JS.fromJson json |> JS.toRecord

--main = (parseAnswer >> asText)  <~ getWallPosts

parseAnswer json = getArray (getJsonArray json)

getJsonArray : Json.Value -> Maybe (Json.Value)
getJsonArray json = getDict "response" (Just json)  |> ( getDict "items" )

getDict : String -> Maybe( Json.Value ) -> Maybe (Json.Value)
getDict tagName json = case json of
    Just (Json.Object dict) -> parseDict tagName dict
    _ -> Nothing

parseDict tagName dict = Dict.get tagName dict 

getArray : Maybe( Json.Value) -> [Json.Value]
getArray json = case json of
    Just (Json.Array arr) -> arr
    _ -> []

type Post = {text:String, photos:[String], musics:[String]}

toRecord : [Json.Value] -> [Post]
toRecord jsonArr = []

--}



{-- display posts by Elm Graphics --}
displayHtml posts = (toElement 1000 700 (postColumns << sortPosts <| posts))


displayGroups : [Group] -> Element
displayGroups groups = 
    flow right (map getGroup groups)

getGroup group = image 30 30 group.photo_50 |> GI.clickable groupClick.handle group.id

displayPosts = sortPosts >> displayColumns 


displayColumns : [Post] -> Element
displayColumns posts =
    let (posts1, posts2, posts3) = dividePosts posts 
    in 
        flow right [
            getColumn posts1, spacer 20 20,
            getColumn posts2, spacer 20 20,
            getColumn posts3]




getColumn : [Post] -> Element
getColumn posts = flow down (map getElement posts)

getElement : Post -> Element
getElement post = 
    flow down [ 
        getImages post.photos,
        getText post.text,
        getFooter post,
        spacer 0 30 |> color white 
    ]

getImages : [Photo] -> Element
getImages photos = 
    let ph = case photos of
        h :: t -> [h]
        _ -> []
    in
        flow right (map getImage ph)

getImage : Photo -> Element
getImage photo = 
    let photoHeight = getPhotoHeight 250 photo
    in image 250 photoHeight photo.photo_604

getPhotoHeight : Int -> Photo -> Int
getPhotoHeight w photo = 
    round (toFloat w * toFloat photo.height / toFloat photo.width)

getText : String -> Element
getText text = 
    toText (String.left 140 text) 
        |> Text.height 11
        |> typeface ["tahoma"]
        |> leftAligned 
        |> GE.width 250

getFooter : Post -> Element
getFooter post = 
    container 250 20 bottomLeft <| flow right [ 
        image 14 10 "http://www.korolev-tv.ru/img/press/like_vk.png",
        leftAligned <| bold <| monospace <| toText (show post.likes) 
    ]

{----------------- Test data ---------------}

testPost = {
    text    = "Properties List. A listing of the CSS properties yes this ok hello..... \n\nBudda",
    likes   = 100,
    date    = 500,
    photos  = [],
    audios  = []
    }

testPhoto = {
    photo_75    = "http://cs622827.vk.me/v622827997/95/QECn2X8Yg7Y.jpg",
    photo_130   = "http://cs622827.vk.me/v622827997/95/QECn2X8Yg7Y.jpg",
    photo_604   = "http://cs622827.vk.me/v622827997/95/QECn2X8Yg7Y.jpg",
    width       = 604, 
    height      = 340
    }


{----------------- Divide posts ---------------}

{-- divp : [a] -> [a] -> [a] -> [a] -> Int -> ([a], [a], [a])
divp posts1 posts2 posts3 posts acc = 
    case posts of
        [] -> (posts1, posts2, posts3)
        h :: t -> 
            case acc % 3 of
                0 -> divp (h :: posts1) posts2 posts3 t (acc+1)
                1 -> divp posts1 (h :: posts2) posts3 t (acc+1)
                2 -> divp posts1 posts2 (h :: posts3) t (acc+1) --}


{----------------- Sort posts ---------------}

sortPosts : [Post] -> [Post] 
sortPosts posts = sortWith flipSort posts

flipSort : Post -> Post -> Order
flipSort a b =
     if | a.likes > b.likes -> LT
        | a.likes == b.likes -> EQ
        | a.likes < b.likes -> GT