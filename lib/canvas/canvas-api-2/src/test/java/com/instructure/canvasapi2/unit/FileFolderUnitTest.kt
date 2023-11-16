/*
 * Copyright (C) 2017 - present Instructure, Inc.
 *
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 *
 */

package com.instructure.canvasapi2.unit

import com.instructure.canvasapi2.models.FileFolder
import com.instructure.canvasapi2.utils.parse
import org.intellij.lang.annotations.Language
import org.junit.Assert
import org.junit.Test


class FileFolderUnitTest : Assert() {

    @Test
    fun testFiles() {
        val files: Array<FileFolder> = filesJSON.parse()

        Assert.assertNotNull(files)
        Assert.assertEquals(3, files.size)

        for (file in files) {
            testCommonAttributes(file)

            Assert.assertNotNull(file.folderId)
            Assert.assertNotNull(file.size)
            Assert.assertNotNull(file.contentType)
            Assert.assertNotNull(file.url)
            Assert.assertNotNull(file.displayName)
            Assert.assertNotNull(file.thumbnailUrl)
            Assert.assertNotNull(file.lockInfo?.unlockAt)
        }
    }

    @Test
    fun testFolders() {
        val folders: Array<FileFolder> = foldersJSON.parse()

        Assert.assertNotNull(folders)
        Assert.assertEquals(3, folders.size)

        for (file in folders) {
            testCommonAttributes(file)

            Assert.assertNotNull(file.parentFolderId)
            Assert.assertNotNull(file.contextId)
            Assert.assertNotNull(file.position)
            Assert.assertNotNull(file.foldersCount)
            Assert.assertNotNull(file.contextType)
            Assert.assertNotNull(file.name)
            Assert.assertNotNull(file.foldersUrl)
            Assert.assertNotNull(file.filesUrl)
            Assert.assertNotNull(file.fullName)
        }
    }

    private fun testCommonAttributes(fileFolder: FileFolder) {
        Assert.assertNotNull(fileFolder.id)
        Assert.assertNotNull(fileFolder.createdDate)
        Assert.assertNotNull(fileFolder.updatedDate)
        Assert.assertNotNull(fileFolder.unlockDate)
        Assert.assertNotNull(fileFolder.lockDate)
        Assert.assertNotNull(fileFolder.isLocked)
        Assert.assertNotNull(fileFolder.isHidden)
        Assert.assertNotNull(fileFolder.isLockedForUser)
        Assert.assertNotNull(fileFolder.isHiddenForUser)
    }

    @Language("JSON")
    private val filesJSON = """
      [
        {
          "id": 63383591,
          "folder_id": 2873264,
          "content-type": "video/mp4",
          "display_name": "12_limits_continuity.mp4",
          "url": "https://mobiledev.instructure.com/files/63383591/download?download_frd=1",
          "size": 29739338,
          "created_at": "2015-01-22T22:41:01Z",
          "updated_at": "2015-03-10T21:12:01Z",
          "unlock_at": "2015-03-10T21:12:01Z",
          "locked": false,
          "hidden": false,
          "lock_at": "2015-01-22T22:41:01Z",
          "hidden_for_user": false,
          "thumbnail_url": "https://nv.instructuremedia.com/p/9/thumbnail/entry_id/m-5rBaCRyiyvBByuS72NS5XtuXpdioHAku/width/140/height/100/bgcolor/ffffff/type/2/vid_sec/5",
          "locked_for_user": false,
          "lock_info": {
            "asset_string": "attachment_63383591",
            "unlock_at": "2015-03-26T06:00:00Z"
          }
        },
        {
          "id": 46772199,
          "folder_id": 4815146,
          "content-type": "image/jpeg",
          "display_name": "1387235693988.jpg",
          "url": "https://mobiledev.instructure.com/files/46772199/download?download_frd=1",
          "size": 16152,
          "created_at": "2014-01-20T20:47:21Z",
          "updated_at": "2015-01-08T10:01:49Z",
          "unlock_at": "2015-03-10T21:12:01Z",
          "locked": false,
          "hidden": false,
          "lock_at": "2015-01-22T22:41:01Z",
          "hidden_for_user": false,
          "thumbnail_url": "https://instructure-uploads.s3.amazonaws.com/thumbnails/46772199/1387235693988_thumb.jpg?AWSAccessKeyId=AKIAJFNFXH2V2O7RPCAA&Expires=1427302233&Signature=eQQA4I7YMn%2BENlC7qlXk1UNms0c%3D",
          "locked_for_user": false,
          "lock_info": {
            "asset_string": "attachment_63383591",
            "unlock_at": "2015-03-26T06:00:00Z"
          }
        },
        {
          "id": 49303928,
          "folder_id": 4815146,
          "content-type": "image/jpeg",
          "display_name": "1393530686715-1.jpg",
          "url": "https://mobiledev.instructure.com/files/49303928/download?download_frd=1",
          "size": 1688752,
          "created_at": "2014-04-07T16:23:59Z",
          "updated_at": "2015-01-08T11:08:04Z",
          "unlock_at": "2015-03-10T21:12:01Z",
          "locked": false,
          "hidden": false,
          "lock_at": "2015-01-22T22:41:01Z",
          "hidden_for_user": false,
          "thumbnail_url": "https://instructure-uploads.s3.amazonaws.com/thumbnails/49303928/1393530686715_thumb.jpg?AWSAccessKeyId=AKIAJFNFXH2V2O7RPCAA&Expires=1427302233&Signature=9qXqCnaFcqNHqZ08KDmxZ3alWhA%3D",
          "locked_for_user": false,
          "lock_info": {
            "asset_string": "attachment_63383591",
            "unlock_at": "2015-03-26T06:00:00Z"
          }
        }
      ]"""

    @Language("JSON")
    private val foldersJSON = """
      [
        {
          "context_id": 833052,
          "context_type": "Course",
          "created_at": "2012-10-06T00:05:33Z",
          "full_name": "course dsfsd",
          "id": 2873264,
          "lock_at": "2012-12-06T00:05:33Z",
          "name": "course files",
          "parent_folder_id": 7151579,
          "position": 1,
          "unlock_at": "2012-11-06T00:05:33Z",
          "updated_at": "2012-10-06T00:05:33Z",
          "locked": false,
          "folders_url": "https://panda.instructure.com/api/v1/folders/12345/folders",
          "files_url": "https://panda.instructure.com/api/v1/folders/12345/files",
          "files_count": 11,
          "folders_count": 3,
          "hidden": false,
          "locked_for_user": false,
          "hidden_for_user": false
        },
        {
          "context_id": 833052,
          "context_type": "Course",
          "created_at": "2014-06-29T18:27:35Z",
          "full_name": "course files/parental_guidance_photos/First Day of Class",
          "id": 7151597,
          "lock_at": "2012-12-06T00:05:33Z",
          "name": "First Day of Class",
          "parent_folder_id": 7151579,
          "position": 1,
          "unlock_at": "2012-12-06T00:05:33Z",
          "updated_at": "2014-06-29T18:27:35Z",
          "locked": false,
          "folders_url": "https://panda.instructure.com/api/v1/folders/12345/folders",
          "files_url": "https://panda.instructure.com/api/v1/folders/12345/files",
          "files_count": 7,
          "folders_count": 0,
          "hidden": false,
          "locked_for_user": false,
          "hidden_for_user": false
        },
        {
          "context_id": 833052,
          "context_type": "Course",
          "created_at": "2013-08-28T23:13:03Z",
          "full_name": "course files/unfiled/Level 2",
          "id": 5703450,
          "lock_at": "2012-12-06T00:05:33Z",
          "name": "Level 2",
          "parent_folder_id": 4815146,
          "position": 1,
          "unlock_at": "2012-12-06T00:05:33Z",
          "updated_at": "2013-08-28T23:13:03Z",
          "locked": false,
          "folders_url": "https://panda.instructure.com/api/v1/folders/12345/folders",
          "files_url": "https://panda.instructure.com/api/v1/folders/12345/files",
          "files_count": 3,
          "folders_count": 1,
          "hidden": false,
          "locked_for_user": false,
          "hidden_for_user": false
        }
      ]"""
}
