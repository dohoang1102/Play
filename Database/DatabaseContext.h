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

@class AudioStream;
@class Playlist;

@interface DatabaseContext : NSObject
{
	sqlite3					*_db;			// The database
	NSMutableDictionary		*_sql;			// Prepared SQL statements
	
	NSMapTable				*_streams;		// Registered streams
	NSMapTable				*_playlists;	// Registered playlists
	
//	NSUndoManager			*_undoManager;	// For undo/redo management
	
	BOOL					_hasActiveTransaction;
}

// ========================================
// Database connection
- (void) connectToDatabase:(NSString *)databasePath;
- (void) disconnectFromDatabase;
- (BOOL) isConnectedToDatabase;

// ========================================
// Action methods
- (IBAction) undo:(id)sender;
- (IBAction) redo:(id)sender;

- (IBAction) save:(id)sender;
- (IBAction) revert:(id)sender;

// ========================================
// AudioStream support
- (NSArray *) allStreams;
- (NSArray *) streamsForPlaylist:(Playlist *)playlist;
- (AudioStream *) streamForID:(NSNumber *)objectID;

- (BOOL) insertStream:(AudioStream *)stream;
- (void) saveStream:(AudioStream *)stream;
- (void) deleteStream:(AudioStream *)stream;
- (void) revertStream:(AudioStream *)stream;

- (void) audioStream:(AudioStream *)stream didChangeForKey:(NSString *)key;

// ========================================
// Playlist support
- (NSArray *) allPlaylists;
- (Playlist *) playlistForID:(NSNumber *)objectID;

- (BOOL) insertPlaylist:(Playlist *)playlist;
- (void) savePlaylist:(Playlist *)playlist;
- (void) deletePlaylist:(Playlist *)playlist;
- (void) revertPlaylist:(Playlist *)playlist;

- (void) playlist:(Playlist *)playlist didChangeForKey:(NSString *)key;

//- (NSUndoManager *) undoManager;

@end
