// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse and unparse this JSON data, add this code to your project and do:
//
//    contents, err := UnmarshalContents(bytes)
//    bytes, err = contents.Marshal()

package main

import (
	"encoding/json"
	"log"
	"strconv"
	"strings"
)

func UnmarshalContents(data []byte) (Contents, error) {
	var r Contents
	err := json.Unmarshal(data, &r)
	return r, err
}

func (r *Contents) Marshal() ([]byte, error) {
	return json.Marshal(r)
}

func (r *Image) GetSize() int {
	split := strings.Split(r.Size, "x")
	f, err := strconv.ParseFloat(split[0], 32)
	if err != nil {
		log.Fatal("err: %v", err)
	}
	return int(f * float64(r.GetScale()))
}

func (r *Image) GetScale() int {
	i, err := strconv.Atoi(strings.Split(r.Scale, "x")[0])
	if err != nil {
		log.Fatal("err: %v", err)
	}
	return i
}

type Contents struct {
	Images []Image `json:"images"`
	Info   Info    `json:"info"`
}

type Image struct {
	Size     string `json:"size"`
	Idiom    Idiom  `json:"idiom"`
	Filename string `json:"filename"`
	Scale    Scale  `json:"scale"`
}

type Info struct {
	Version int64  `json:"version"`
	Author  string `json:"author"`
}

type Idiom string

const (
	IosMarketing Idiom = "ios-marketing"
	Ipad         Idiom = "ipad"
	Iphone       Idiom = "iphone"
)

type Scale = string

const (
	The1X Scale = "1x"
	The2X Scale = "2x"
	The3X Scale = "3x"
)
