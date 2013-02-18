package org.springsource.showcases.pizzashop.web;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.roo.addon.web.mvc.controller.scaffold.RooWebScaffold;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springsource.showcases.pizzashop.domain.Base;


@RequestMapping("/bases")
@Controller
@RooWebScaffold(path = "bases", formBackingObject = Base.class)
public class BaseController {
	
	private static final Logger logger = LoggerFactory.getLogger(BaseController.class);
	
	@ResponseStatus(HttpStatus.CREATED)
	@RequestMapping(method = RequestMethod.POST, consumes = "application/json", produces = "application/json")
	public @ResponseBody Base createFromJson(@RequestBody Base base) {
		base.persist();
		return Base.findBase(base.getId());
	}
	
	@RequestMapping(value = "/{id}", method = RequestMethod.GET, produces = "application/json")
	public @ResponseBody Base showJson(@PathVariable("id") Long id) {
		return Base.findBase(id);
	}

	@RequestMapping(method = RequestMethod.GET, produces = "application/json")
	public @ResponseBody List<Base> listJson(@RequestParam(value = "page", required = false) Integer page, @RequestParam(value = "size", required = false) Integer size) {
		return getBases(page, size);
	}
	
	@RequestMapping(method = RequestMethod.PUT, consumes = "application/json", produces = "application/json")
	public @ResponseBody Base updateFromJson(@RequestBody Base base) {
		base.merge();
		return Base.findBase(base.getId());
	}
	
	@RequestMapping(value = "/{id}", method = RequestMethod.DELETE, produces = "application/json")
	public @ResponseBody List<Base> deleteJson(@PathVariable("id") Long id, @RequestParam(value = "page", required = false) Integer page, @RequestParam(value = "size", required = false) Integer size) {
		Base base = Base.findBase(id);
		base.remove();
		return getBases(page, size);
	}
	
	// helpers
	
	private List<Base> getBases(Integer page, Integer size) {
		if (page != null || size != null) {
			int sizeNo = size == null ? 10 : size.intValue();
			final int firstResult = page == null ? 0 : (page.intValue() - 1) * sizeNo;
			return Base.findBaseEntries(firstResult, sizeNo);
		} else {
			return Base.findAllBases();
		}
	}

}
