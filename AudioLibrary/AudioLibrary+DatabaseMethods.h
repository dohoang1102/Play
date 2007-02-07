/*
 *  $Id$
 *
 *  Copyright (C) 2006 - 2007 Stephen F. Booth <me@sbooth.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import <Cocoa/Cocoa.h>
#include <sqlite3.h>

#import "AudioLibrary.h"
#import "AudioStream.h"
#import "Playlist.h"

// ========================================
// Database Methods
// To support moving to a different datastore in the future,
// all access to the database is done in these methods.
// ========================================
@interface AudioLibrary (DatabaseMethods)

// ========================================
// Prepared SQL statement management
- (void) prepareSQL;
- (void) finalizeSQL;
- (sqlite3_stmt *) preparedStatementForAction:(NSString *)action;

// ========================================
// Database connection
- (void) connectToDatabase:(NSString *)databasePath;
- (void) disconnectFromDatabase;

// ========================================
// Transaction support
- (void) beginTransaction;
- (void) commitTransaction;
- (void) rollbackTransaction;

// ========================================
// Table creation
- (void) createStreamTable;
- (void) createPlaylistTable;

- (void) createEntryTableForPlaylist:(Playlist *)playlist;
- (void) createEntryTableForStaticPlaylist:(Playlist *)playlist;
- (void) createEntryTableForFolderPlaylist:(Playlist *)playlist;
- (void) createEntryTableForDynamicPlaylist:(Playlist *)playlist;

- (void) dropEntryTableForPlaylist:(Playlist *)playlist;

// ========================================
// Data retrieval
- (void) fetchData;

- (void) fetchStreams;
- (void) fetchPlaylists;

- (void) fetchStreamsForPlaylist:(Playlist *)playlist;
- (void) fetchStreamsForStaticPlaylist:(Playlist *)playlist;
- (void) fetchStreamsForFolderPlaylist:(Playlist *)playlist;
- (void) fetchStreamsForDynamicPlaylist:(Playlist *)playlist;

// ========================================
// Stream manipulation
- (AudioStream *) insertStreamForURL:(NSURL *)url streamInfo:(NSDictionary *)streamInfo;
- (void) updateStream:(AudioStream *)stream;
- (void) deleteStream:(AudioStream *)stream;

// ========================================
// Playlist manipulation
- (Playlist *) insertPlaylistOfType:(ePlaylistType)type name:(NSString *)name;
- (void) updatePlaylist:(Playlist *)playlist;
- (void) deletePlaylist:(Playlist *)playlist;

- (void) addStreamIDs:(NSArray *)streamIDs toPlaylist:(Playlist *)playlist;

@end
