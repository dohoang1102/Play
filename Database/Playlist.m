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

#import "Playlist.h"
#import "Playlist+DatabaseContextMethods.h"
#import "DatabaseContext.h"

NSString * const	PlaylistDidChangeNotification			= @"org.sbooth.Play.PlaylistDidChangeNotification";

NSString * const	PlaylistIDKey							= @"id";
NSString * const	PlaylistNameKey							= @"name";

NSString * const	StatisticsDateCreatedKey				= @"dateCreated";

@interface Playlist (Private)
- (DatabaseContext *) databaseContext;
@end

@implementation Playlist

+ (id) insertPlaylistWithInitialValues:(NSDictionary *)keyedValues inDatabaseContext:(DatabaseContext *)context;
{
	NSParameterAssert(nil != context);
	
	Playlist *playlist = [[Playlist alloc] initWithDatabaseContext:context];
	
	// Call init: methods here to avoid sending change notifications to the context
	[playlist initValue:[NSDate date] forKey:StatisticsDateCreatedKey];
	[playlist initValuesForKeysWithDictionary:keyedValues];
	
	if(NO == [context insertPlaylist:playlist]) {
		[playlist release], playlist = nil;
	}
	
	return [playlist autorelease];
}

- (void) dealloc
{
	[_databaseContext release], _databaseContext = nil;
	
	[_databaseKeys release], _databaseKeys = nil;
	
	[_savedValues release], _savedValues = nil;
	[_changedValues release], _changedValues = nil;
	
	[super dealloc];
}

- (id) valueForKey:(NSString *)key
{
	if([_databaseKeys containsObject:key]) {
		id value = [_changedValues valueForKey:key];
		if(nil == value) {
			value = [_savedValues valueForKey:key];
		}
		
		return value;
	}
	else {
		return [super valueForKey:key];
	}
}

- (void) setValue:(id)value forKey:(NSString *)key
{
	if([_databaseKeys containsObject:key]) {
		//		[[[[self databaseContext] undoManager] prepareWithInvocationTarget:self] setValue:[self valueForKey:key] forKey:key];
		
		if([[_savedValues valueForKey:key] isEqual:value]) {
			[_changedValues removeObjectForKey:key];
		}
		else {
			[_changedValues setValue:value forKey:key];			
		}
		
		[[self databaseContext] playlist:self didChangeForKey:key];
	}
	else {
		[super setValue:value forKey:key];
	}
}

- (NSArray *) streams
{
	return [[self databaseContext] streamsForPlaylist:self];
}

- (BOOL) isPlaying							{ return _isPlaying; }
- (void) setIsPlaying:(BOOL)isPlaying		{ _isPlaying = isPlaying; }

- (void) save
{
	[[self databaseContext] savePlaylist:self];
}

- (void) revert
{
	NSEnumerator	*changedKeys	= [[_changedValues allKeys] objectEnumerator];
	NSString		*key			= nil;
	
	while((key = [changedKeys nextObject])) {
		[self willChangeValueForKey:key];
		[_changedValues removeObjectForKey:key];
		[self didChangeValueForKey:key];
	}
}

- (void) delete
{
	[[self databaseContext] deletePlaylist:self];
}

- (unsigned) hash
{
	// Database ID is guaranteed to be unique
	return [[_savedValues valueForKey:PlaylistIDKey] unsignedIntValue];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"[%@] %@", [self valueForKey:PlaylistIDKey], [self valueForKey:PlaylistNameKey]];
}

@end

@implementation Playlist (DatabaseContextMethods)

- (id) initWithDatabaseContext:(DatabaseContext *)context
{
	NSParameterAssert(nil != context);
	
	if((self = [super init])) {
		_databaseContext = [context retain];
		
		_savedValues	= [[NSMutableDictionary alloc] init];
		_changedValues	= [[NSMutableDictionary alloc] init];
		
		_databaseKeys	= [[NSArray alloc] initWithObjects:
			PlaylistIDKey, 
			PlaylistNameKey, 
			
			StatisticsDateCreatedKey,
			StatisticsFirstPlayedDateKey,
			StatisticsLastPlayedDateKey,
			StatisticsPlayCountKey,
						
			nil];
		
		return self;
	}
	return nil;
}

- (void) initValue:(id)value forKey:(NSString *)key
{
	[self willChangeValueForKey:key];
	[_changedValues removeObjectForKey:key];
	[_savedValues setValue:value forKey:key];
	[self didChangeValueForKey:key];
}

- (void) initValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
	NSEnumerator	*savedKeys		= [keyedValues keyEnumerator];
	NSString		*key			= nil;
	
	while((key = [savedKeys nextObject])) {
		[self initValue:[keyedValues valueForKey:key] forKey:key];
	}
}

- (BOOL) hasChanges
{
	return 0 != [_changedValues count];
}

- (NSDictionary *) changes
{
	return [[_changedValues copy] autorelease];
}

#pragma mark Callbacks

- (void) didSave
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PlaylistDidChangeNotification 
														object:self 
													  userInfo:[NSDictionary dictionaryWithObject:self forKey:PlaylistObjectKey]];
}

@end

@implementation Playlist (Private)

- (DatabaseContext *) databaseContext
{
	return _databaseContext;
}

@end
