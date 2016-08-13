-- This example queries your light details and then repeatedly blinks one light by turning it on and off.


module Main exposing (..)

import Debug
import Html exposing (text)
import Html.App exposing (program)
import Task
import Time
import Hue
import Hue.Lights


-- IMPORTANT: Configure your bridge and light details here before running this program!


baseUrl =
    "http://192.168.1.1"


username =
    "D4yG2jaaJRlKWriuoeNyD25js8aJ53lslaj73DK7"


myBridge =
    Hue.bridgeRef baseUrl username


myLight =
    Hue.lightRef myBridge "3"



-- This is how you list all available lights


listLightsTask : Task.Task Hue.Error (List Hue.Lights.LightDetails)
listLightsTask =
    Hue.listLights myBridge
        |> Task.map (Debug.log "light details")
        >> Task.mapError (Debug.log "an error occured")


listLightsCmd : Cmd Msg
listLightsCmd =
    Task.perform (always Noop) (always Noop) listLightsTask



-- This is how you blink the lights


turnOnTask =
    Hue.updateLight myLight [ Hue.turnOn ]
        |> Task.map (Debug.log "turned light on")
        >> Task.mapError (Debug.log "an error occured")


turnOffTask =
    Hue.updateLight myLight [ Hue.turnOff ]
        |> Task.map (Debug.log "turned light off")
        >> Task.mapError (Debug.log "an error occured")


turnOnCmd : Cmd Msg
turnOnCmd =
    Task.perform (always Noop) (always Noop) turnOnTask


turnOffCmd : Cmd Msg
turnOffCmd =
    Task.perform (always Noop) (always Noop) turnOffTask


toggleEvery4Seconds : Sub Msg
toggleEvery4Seconds =
    Time.every (4 * Time.second) (always ToggleCmd)



-- Boilerplate to set up an application that blinks a light.


type alias Model =
    { willTurnOn : Bool
    }


type Msg
    = Noop
    | ToggleCmd


update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        ToggleCmd ->
            let
                cmd =
                    if model.willTurnOn then
                        turnOnCmd
                    else
                        turnOffCmd
            in
                ( { willTurnOn = not model.willTurnOn }, cmd )


main : Program Never
main =
    program
        { init = ( { willTurnOn = True }, listLightsCmd )
        , update = update
        , view = (\_ -> text "Configure your bridge details, then open your developer tools and see your light details")
        , subscriptions = always toggleEvery4Seconds
        }