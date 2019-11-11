// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse and unparse this JSON data, add this code to your project and do:
//
//    artboardInfo, err := UnmarshalArtboardInfo(bytes)
//    bytes, err = artboardInfo.Marshal()

package main

import (
	"encoding/json"
	"log"
	"strconv"
	"strings"
)

func UnmarshalArtboardInfo(data []byte) (ArtboardInfo, error) {
	var r ArtboardInfo
	err := json.Unmarshal(data, &r)
	return r, err
}

func (r *ArtboardInfo) Marshal() ([]byte, error) {
	return json.Marshal(r)
}

func (r *Artboard) Size() int64 {
	return r.Rect.X
}

func (r *Artboard) GetSize() int {
	return int(r.Rect.Width)
}

func (r *Artboard) GetScale() int {
	split := strings.Split(r.Name, "@")
	if len(split) < 2 {
		return 1
	}
	i, err := strconv.Atoi(strings.Split(split[1], "x")[0])
	if err != nil {
		log.Fatal("err: %v", err)
	}
	return i
}

type ArtboardInfo struct {
	Pages []Page `json:"pages"`
}

type Page struct {
	ID        string     `json:"id"`
	Name      string     `json:"name"`
	Bounds    string     `json:"bounds"`
	Artboards []Artboard `json:"artboards"`
}

type Artboard struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Rect    Rect   `json:"rect"`
	Trimmed Rect   `json:"trimmed"`
}

type Rect struct {
	Y      int64 `json:"y"`
	X      int64 `json:"x"`
	Width  int64 `json:"width"`
	Height int64 `json:"height"`
}
